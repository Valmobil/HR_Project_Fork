public with sharing class InterviewSummaryManager {
    private final Interview_Summary__c summary;
    private final ContentVersion cv;

    private String summaryFileName;
    private String activitiesFileName;
    private String summaryText;
    private String activitiesText;
    private String sharedStringsText;

    private List<List<String>> minScores;
    private List<Integer> maxScores;
    private List<String> gradesToInsert;
    private List<List<String>> dataToUpsert;
    private List<Integer> missedLevelData;
    private List<Integer> failedMusts;
    private List<String> percentageTexts;
    private List<String> sharedStringsList;
    private List<String> topicsFromTable;
    private List<Integer> activitiesTopicRows;

    private class CellSubstringGenerator {
        private Integer searchLeftIndex = 0;
        private final String xmlText;

        public CellSubstringGenerator(String xmlText) {
            this.xmlText = xmlText;
        }

        public String generateUpToNextCellSubstring(String value, String cell, Boolean isCellNumber) {
            //Returns the substring starting from the searchLeftIndex (which is not necessarily start of cell's xml)
            //and ending with the end of edited cell's xml
            //moves search index to the point after the target cell in original text
            Integer cellTextIndex = xmlText.indexOf('<c r="' + cell, searchLeftIndex);
            Integer vTagIndex = xmlText.indexOf('<v>', cellTextIndex);
            Integer nextCellIndex = xmlText.indexOf('<c ', cellTextIndex + 1);
            Boolean doesValueExist = (vTagIndex != -1) && ((nextCellIndex == -1) || vTagIndex < nextCellIndex);
            String cellTagEndText = doesValueExist ? '<v>' : '/>';

            Integer cellEndTextIndex = xmlText.indexOf(cellTagEndText, cellTextIndex);
            String toAdd = (doesValueExist ? '<v>' : (isCellNumber ? '><v>' : ' t="str"><v>')) + value + '</v></c>';
            String newXmlText = xmlText.substring(searchLeftIndex, cellEndTextIndex) + toAdd;
            String cellEndText = doesValueExist ? '</c>' : '/>';
            searchLeftIndex = xmlText.indexOf(cellEndText, cellTextIndex) + cellEndText.length();
            return newXmlText;
        }

        public Integer getSearchLeftIndex() {
            return searchLeftIndex;
        }
    }

    private class CellValueReader {
        private Integer searchLeftIndex = 0;
        private final String xmlText;

        public CellValueReader(String xmlText) {
            this.xmlText = xmlText;
        }

        public String getCellValue(String cell) {
            //returns cell's value contained in <v> tag
            //shifts search index to right after the cell in xmlText
            Integer cellTextIndex = xmlText.indexOf('<c r="' + cell, searchLeftIndex);
            Integer cellEndTextIndex = xmlText.indexOf('</c>', cellTextIndex);
            searchLeftIndex = cellEndTextIndex + 4; //'</c>'.length()
            String cellText = xmlText.substring(cellTextIndex, cellEndTextIndex);
            return cellText.substringBetween('<v>', '</v>');
        }

        public Integer getSearchLeftIndex() {
            return searchLeftIndex;
        }

        public void setSearchLeftIndex(Integer value) {
            searchLeftIndex = value;
        }
    }

    public InterviewSummaryManager(Interview_Summary__c summary, ContentVersion cv) {
        this.summary = summary;
        this.cv = cv;
    }

    public void fillInterviewSummaryTable() {
        Zippex z = new Zippex(this.cv.VersionData);
        getStatusAndActivitiesFileNames(z);
        summaryText = z.getFile(summaryFileName).toString();
        activitiesText = z.getFile(activitiesFileName).toString();
        sharedStringsText = z.getFile(Constants.XML_SHAREDSTRINGS_PATH).toString();
        
        //Change summary file
        String newSummaryText = createSummaryFileText();
        z.removeFile(summaryFileName);
        z.addFile(summaryFileName, Blob.valueOf(newSummaryText), null);

        //Read data
        readSharedStrings();
        readTopicsFromTable();
        readActivitiesData();

        //Compute & generate data for upsertion
        gradesToInsert = getTopicsWithGrades(summary.Interview_Answers__r);
        generateDataForUpsert();
        generatePercentageTexts();

        //Change activities file
        String newActivities = createActivitiesFileText();
        z.removeFile(activitiesFileName);
        z.addFile(activitiesFileName, Blob.valueOf(newActivities), null);

        //Insert new file version
        ContentVersion cvXlsx = new ContentVersion();
        cvXlsx.Title = cv.Title;
        cvXlsx.PathOnClient = cv.Title + '.' + cv.FileExtension;
        cvXlsx.ContentDocumentId = cv.ContentDocumentId;
        cvXlsx.VersionData = z.getZipArchive();
        insert cvXlsx;
    }

    @TestVisible
    private static List<String> getInterviewQuestionTopicsPicklist() {
        List<Interview_Question_Topic__c> topics = [SELECT Name FROM Interview_Question_Topic__c];
        List<String> result = new List<String>();
        for (Interview_Question_Topic__c t : topics) {
            result.add(t.Name.normalizeSpace()); //when you copy topic from Excel it may contain some spaces in the end
        }
        return result;
    }

    private List<String> getStatusAndActivitiesFileNames(Zippex z) {
        //All tabs are saved as 'xl/worksheets/sheet#.xml', # goes in same order as tabs go
        //starting from 1. If you need to find the number #, you get into xl/workbook.xml and
        //search for <sheet> tag. all info is there.
        String summaryIndex = '';
        String activitiesIndex = '';
        String workbookXml = z.getFile(Constants.XML_WORKBOOK_PATH).toString();
        while ((summaryIndex == '' || activitiesIndex == '') && workbookXml.indexOf('<sheet ') != -1) {
            workbookXml = workbookXml.substring(workbookXml.indexOf('<sheet ') + 7);
            if (workbookXml.substringBetween('name="','"') == Constants.SUMMARY_TAB_TITLE) {
                summaryIndex = workbookXml.substringBetween('"rId','"');
            }
            else if (workbookXml.substringBetween('name="','"') == Constants.ACTIVITIES_TAB_TITLE) {
                activitiesIndex = workbookXml.substringBetween('"rId','"');
            }
        }
        if (summaryIndex == '' || activitiesIndex == '') {
            throw new XmlException(Constants.TAB_NOT_FOUND_MSG);
        }
        summaryFileName = Constants.XML_WORKSHEET_PATH_PREFIX + summaryIndex + '.xml';
        activitiesFileName = Constants.XML_WORKSHEET_PATH_PREFIX + activitiesIndex + '.xml';
        return new List<String>{summaryFileName, activitiesFileName};
    }

    private String createSummaryFileText() {
        String newSummaryText = '';
        String yearsApiName = Interview_Summary__c.Years_of_Experience__c.getDescribe().getName();
        CellSubstringGenerator generator = new CellSubstringGenerator(summaryText);
        for (Integer i = 0; i < Constants.SUMMARY_CELLS.size(); i++) {
            String fieldValue = String.valueOf(summary.get(Constants.SUMMARY_FIELDS_API[i]));
            if (fieldValue != null) {
                Boolean isYearsField = Constants.SUMMARY_FIELDS_API[i] == yearsApiName;
                newSummaryText += generator.generateUpToNextCellSubstring(fieldValue, Constants.SUMMARY_CELLS[i], isYearsField);
            }
        }
        newSummaryText += summaryText.substring(generator.getSearchLeftIndex());
        return newSummaryText;
    }

    private void readSharedStrings() {
        //not using CellValueReader for this method because there are no "cells" in this file, only string values
        Integer searchLeftIndex = 0;
        sharedStringsList = new List<String>();
        Integer siIndex = sharedStringsText.indexOf('<si>');
        while (siIndex != -1) {
            Integer siEndIndex = sharedStringsText.indexOf('</si>', siIndex);
            String sharedStringXml = sharedStringsText.substring(siIndex, siEndIndex);
            sharedStringsList.add(generateSharedString(sharedStringXml));
            siIndex = sharedStringsText.indexOf('<si>', siEndIndex);
        }
    }

    private String generateSharedString(String sharedStringXml) {
        if (sharedStringXml.indexOf('<r>') == -1) { //One-row text, just <t some_attributes>text</t>
            String result = sharedStringXml.substring(sharedStringXml.indexOf('<t'));
            return result.substringBetween('>', '</t>').normalizeSpace().unescapeHTML4();
        } else { //Multiple-row text, can be retrieved if necessary, we don't need them
            return null;
        }
    }

    private void readTopicsFromTable() {
        topicsFromTable = new List<String>();
        activitiesTopicRows = new List<Integer>();
        CellValueReader reader = new CellValueReader(activitiesText);
        List<String> allTopics = getInterviewQuestionTopicsPicklist();

        Integer nextRowNumber = 1;
        Integer nextRowXmlIndex = activitiesText.indexOf('<c r="A' + nextRowNumber);
        while (nextRowXmlIndex != -1) {
            reader.setSearchLeftIndex(nextRowXmlIndex);
            String cell = 'A' + nextRowNumber;
            String val = sharedStringsList[Integer.valueOf(reader.getCellValue(cell))];
            if (allTopics.contains(val)) {
                topicsFromTable.add(val);
                activitiesTopicRows.add(nextRowNumber);
            }
            nextRowNumber += 1;
            nextRowXmlIndex = activitiesText.indexOf('<c r="A' + nextRowNumber, reader.getSearchLeftIndex());
        }
    }

    private void readActivitiesData() {
        minScores = new List<List<String>>();
        maxScores = new List<Integer>();
        CellValueReader reader = new CellValueReader(activitiesText);
        for (Integer row : activitiesTopicRows) {
            List<String> newRow = new List<String>();
            for (String col : Constants.READ_DATA_COLUMNS) {
                String cellValue = reader.getCellValue(col + row);
                newRow.add(cellValue);
            }
            minScores.add(newRow);

            if (row == 5) {
                for (String col : Constants.MAX_SCORE_COLUMNS) {
                    Integer cellValue = Integer.valueOf(reader.getCellValue(col + row));
                    maxScores.add(cellValue);
                }
            }
        }
    }

    private List<String> getTopicsWithGrades(List<Interview_Answer__c> answers) {
        Map<String, List<Decimal>> numericGrades = new Map<String, List<Decimal>>(); // Each element of the map is 'topic' -> [sum of grades, amount of grades]
        for (String topic : this.topicsFromTable) {
            numericGrades.put(topic, new List<Decimal>{0.0, 0.0});
        }
        for (Interview_Answer__c answer : answers) {
            if (answer.Grade__c != 'Not evaluated') {
                List<Decimal> d = numericGrades.get(answer.Topic__c.normalizeSpace());
                if (d == null) {
                    throw new HandledException(Constants.TOPIC_NOT_FOUND_MSG.replace('{0}', answer.Topic__c));
                }
                d[0] += Constants.GRADE_NAMES_ORG.indexOf(answer.Grade__c);
                d[1] += 1;
            }
        }

        List<String> result = new List<String>();
        for (String topic : this.topicsFromTable) {
            List<Decimal> numericGrade = numericGrades.get(topic);
            String grade = getGradeTitleFromSumAndAmount(numericGrade[0], numericGrade[1]);
            result.add(grade);
        }
        return result;
    }

    private static String getGradeTitleFromSumAndAmount(Decimal sum, Decimal amount) {
        return (amount == 0.0 ? 'Not Evaluated' :
            Constants.GRADE_NAMES_TABLE[Integer.valueOf((sum/amount).round(System.RoundingMode.HALF_UP))]
        );
    }

    private void generateDataForUpsert() {
        dataToUpsert = new List<List<String>>();
        missedLevelData = new List<Integer>();
        failedMusts = new List<Integer>();
        for (Integer i = 0; i < Constants.AMOUNT_OF_GRADES; i++) {
            missedLevelData.add(0);
            failedMusts.add(0);
        }
        Integer amountOfDataRows = activitiesTopicRows.size();
        Integer amountOfDataColumns = Constants.WRITE_DATA_COLUMNS.size();

        for (Integer index = 0; index < amountOfDataRows; index++) {
            List<String> rowData = new List<String>(amountOfDataColumns);
            Integer gradeIndex = Constants.GRADE_NAMES_TABLE.indexOf(gradesToInsert[index]);
            if (gradesToInsert[index] == 'Not Evaluated') {
                gradeIndex = 0; //'Not Evaluated' calculation defaults to 'None'
            } 
            for (Integer i = 0; i < Constants.AMOUNT_OF_GRADES; i++) {
                String missedLevel = gradeIndex < Integer.valueOf(minScores[index][i + Constants.AMOUNT_OF_GRADES]) ? '1' : '0';
                rowData[Constants.AMOUNT_OF_GRADES + i] = missedLevel; //AA - AD
                missedLevelData[i] += Integer.valueOf(missedLevel);
                String missedMin = gradeIndex < Integer.valueOf(minScores[index][i]) ? '1' : '0';
                rowData[2*Constants.AMOUNT_OF_GRADES + i] = missedMin; //AE - AH
                failedMusts[i] += Integer.valueOf(missedMin);
                String cellText = (missedMin == '1' ? '--' : (missedLevel == '1' ? '-' : '+'));
                rowData[i] = cellText; //F - I
            }
            dataToUpsert.add(rowData);
        }
    }

    private void generatePercentageTexts() {
        percentageTexts = new List<String>();
        List<Long> percentages = new List<Long>();
        for (Integer i = 0; i < Constants.AMOUNT_OF_GRADES; i++) {
            percentages.add((100.0 * (maxScores[i] - missedLevelData[i]) / maxScores[i]).round());
        }
        percentages.add(0);

        Integer maxScore = 0;
        for (Integer i = 0; i < Constants.AMOUNT_OF_GRADES; i++) {
            if (failedMusts[i] == 0) {
                if (percentages[i] < 80) {maxScore = 3*i + 1;}
                else if (percentages[i + 1] <= 30) {maxScore = 3*i + 2;}
                else {maxScore = 3*i + 3;}
            }
        }
        percentageTexts.add(Constants.SCORE_NAMES[maxScore]);
        for (Integer i = 0; i < Constants.AMOUNT_OF_GRADES; i++) {
            percentageTexts.add((failedMusts[i] > 0 ? '[' : '') + percentages[i] + '%' + (failedMusts[i] > 0 ? ']' : ''));
        }
    }

    private String createActivitiesFileText() {
        String newActivitiesText = '';
        CellSubstringGenerator generator = new CellSubstringGenerator(activitiesText);

        for (Integer i = 0; i < Constants.PERCENTAGE_CELLS.size(); i++) {
            newActivitiesText += generator.generateUpToNextCellSubstring(percentageTexts[i], Constants.PERCENTAGE_CELLS[i], false);
        }

        Integer amountOfDataRows = activitiesTopicRows.size();
        Integer amountOfDataColumns = Constants.WRITE_DATA_COLUMNS.size();
        for (Integer rowIndex = 0; rowIndex < amountOfDataRows; rowIndex++) {
            Integer row = activitiesTopicRows[rowIndex];
            newActivitiesText += generator.generateUpToNextCellSubstring(gradesToInsert[rowIndex], Constants.GRADE_TEXT_COLUMN + row, false);

            for (Integer i = 0; i < amountOfDataColumns; i++) { 
                String col = Constants.WRITE_DATA_COLUMNS[i];
                newActivitiesText += generator.generateUpToNextCellSubstring(dataToUpsert[rowIndex][i], col + row, false);
            }
        }
        newActivitiesText += activitiesText.substring(generator.searchLeftIndex);
        return newActivitiesText;
    }
}
