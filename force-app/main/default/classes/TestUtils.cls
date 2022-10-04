@isTest
public with sharing class TestUtils {
	public static final String TEST_ACCOUNT_NAME = 'testAccountName';

	public static List<Account> createAccounts() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 10; i++) {
			accounts.add(new Account(Name = 'Test ' + i));
		}
		return accounts;
	}

	public static List<Account> populateAccounts() {
		List<Account> accounts = createAccounts();
		insert accounts;
		return accounts;
	}

	public static Account populateAccount() {
		Account acc = new Account(Name = TEST_ACCOUNT_NAME);
		insert acc;
		return acc;
	}

	public static Contact populateContact() {
		Account a = [Select Id FROM Account LIMIT 1];
		Contact c = new Contact(
			LastName = 'Test Contact',
			AccountId = a.Id,
			Email = 'test@test.com'
			);
		insert c;
		return c;
	}

	public static Case populateCase(Contact c) {
		Case caseToCreate = new Case (
			ContactId = c.Id,
			AccountId = c.AccountId
			);

		insert caseToCreate;
		return caseToCreate;
	}

	public static Document createDocument(String name, Boolean toInsert) {
		List<Folder> f = [SELECT Id, Name FROM Folder WHERE Name = 'Communities Shared Document Folder'];
		System.debug(f);
		Document doc = new Document(
			Name = name,
			Body = Blob.valueOf('Test Data'),
			ContentType = 'text/html',
			DeveloperName = name,
			IsPublic = true,
			FolderId = f.size() == 1 ? f[0].Id : null 
			);
		if (toInsert) {
			insert doc;
		}
		return doc;
	}

	public static List<Lead> createLeads(Integer numOfLeads, Boolean toInsert) {
		List<Lead> leads = new List<Lead>();
		for (Integer i = 0; i < numOfLeads; i++) {
			leads.add(
				new Lead(
					LastName = 'testLead' + Datetime.now().getTime(),
					Company = 'Test Company'
				)
			);
		}
		if (toInsert) {
			insert leads;
		}
		return leads;
	}

	public static List<PricebookEntry> populatePricebookEntries(Boolean toInsert) {
		List<Product2> products = TestUtils.populateProducts(true);
		Id standardPricebookId = Test.getStandardPricebookId();

		List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
		for (Product2 product : products) {
			PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product.Id, UnitPrice = 1, IsActive = true);
			pricebookEntries.add(pricebookEntry);
		}
		if (toInsert) {
			insert pricebookEntries;
		}
		return pricebookEntries;
	}

	public static List<Product2> populateProducts(Boolean toInsert) {
		return populateProducts(toInsert, null);
	}

	public static List<Product2> populateProducts(Boolean toInsert, Id productFamilyId) {
		List<Product2> products = new List<Product2>();
		for (Integer i = 0; i < 200; i++) {
			Product2 product = new Product2(Name = 'Test ' + i, ProductCode = 'Test ' + i, IsActive = true);
			products.add(product);
		}
		if (toInsert) {
			insert products;
		}
		return products;
	}

	public static ContentVersion createTestExcel() {
        Zippex z = new Zippex();
        String workbookXml = ('<sheet name="Summary" sheetId="1" r:id="rId1"/>'
        + '<sheet name="Activities" sheetId="2" r:id="rId2"/>');
        z.addFile(Constants.XML_WORKBOOK_PATH, Blob.valueOf(workbookXml), null);

        String summaryXml = '';
        for (String cell : Constants.SUMMARY_CELLS) {
            summaryXml += '<row r="1"><c r="' + cell + '"/></row>';
        }
        z.addFile('xl/worksheets/sheet1.xml', Blob.valueOf(summaryXml), null);

        String activitiesXml = '';
		String sharedStringsXml = '';
        for (String cell : Constants.PERCENTAGE_CELLS) {
            activitiesXml += '<c r="' + cell + '"<v>yes</v></c>';
        }
        for (Integer row = 0; row < Constants.NUMBER_OF_TEST_ROWS; row++) {
			sharedStringsXml += '<si><t>' + Constants.TEST_TOPIC_TITLE.replace('{0}', '' + row) + '</t></si>';
			activitiesXml += '<c r="A' + row + '"><v>' + row + '</v></c>';
            activitiesXml += '<c r="D' + row + '"/>';
            for (String col : Constants.CREATE_TEST_DATA_COLUMNS){
                activitiesXml += '<c r="' + col + row + '"><v>1</v></c>';
            }
        }
        z.addFile('xl/worksheets/sheet2.xml', Blob.valueOf(activitiesXml), null);
		z.addFile(Constants.XML_SHAREDSTRINGS_PATH, Blob.valueOf(sharedStringsXml), null);

        ContentVersion cv = new ContentVersion();
        cv.Title = 'test';
        cv.PathOnClient = 'test.xlsx';
        cv.VersionData = z.getZipArchive();
        insert cv;
        return cv;
    }

	public static ContentDocument createTestDoc() {
		ContentVersion cv = new ContentVersion();
        cv.Title = 'test';
        cv.PathOnClient = 'test.txt';
        cv.VersionData = Blob.valueOf('hello world');
        insert cv;
        ContentDocument doc = [SELECT Id, Title FROM ContentDocument];
		return doc;
	}

	public static Contact populateContact(Boolean isAccountNeeded) {
		Contact c = new Contact(LastName = 'test', Email = 'test@test.com');
        if (isAccountNeeded) {
			c.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
		}
		insert c;
		return c;
	}

	public static Interview_Summary__c populateInterviewSummary(Contact c) {
		Interview_Summary__c summary = new Interview_Summary__c();
        summary.Interviewee__c = c.Id;
        summary.Gaps__c = 'none';
		insert summary;
		return summary;
	}

	public static List<Interview_Question_Topic__c> populateInterviewTopics() {
		List<Interview_Question_Topic__c> topics = new List<Interview_Question_Topic__c>();
        for (Integer i = 0 ; i < Constants.NUMBER_OF_TEST_ROWS; i++) {
            Interview_Question_Topic__c topic = new Interview_Question_Topic__c();
            topic.Name = Constants.TEST_TOPIC_TITLE.replace('{0}', '' + i);
            topics.add(topic);
        }
        insert topics;
		return topics;
	}

	public static Interview_Answer__c populateInterviewAnswer(Interview_Summary__c summary) {
		Interview_Answer__c a = new Interview_Answer__c();
        a.Interview_Summary__c = summary.Id;
        a.Topic__c = Constants.TEST_TOPIC_TITLE.replace('{0}', '2');
        a.Grade__c = Constants.GRADE_NAMES_ORG[0];
        insert a;
		return a;
	}

	public static User createTestUser(Id profileId, Boolean isInsertNeeded) {
		User u = new User(
            LastName = 'Test Code',
            Email = 'test@test.com',
            Alias = 'Tcode',
            Username = 'test' + Datetime.now().getTime() + '@test.com',
            CommunityNickname = 'test12',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileID = profileId,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            Azure_Principal_Name__c = 'test@test.com'
        );
		if (isInsertNeeded) {insert u;}
		return u;
	}

    public static Event createEvent(Id userId, String subject, String eventType, String newDescription) {
		Event newEvent = new Event(OwnerId = userId, StartDateTime = Datetime.now().addHours(1), EndDateTime = Datetime.now().addHours(2), Subject = subject, Description = newDescription);
		if (eventType != null) {
            Id recordTypeId = Utils.getOutlookRecordTypeId(Constants.RECORD_TYPE_OUTLOOK_EVENT);
			newEvent.RecordTypeId = recordTypeId;
        }
		return newEvent;
    }
}
