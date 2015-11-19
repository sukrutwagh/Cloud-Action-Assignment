/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DataControllerTest {

    static testMethod void ReadDataTest() {
        String queryString = '';
        ActionDataObject ado = null;
        
        ado = DataController.ReadData(queryString);
        System.assert(COM_Utils.isNotEmpty(ado.Errors));
        
        queryString = ' Invalid query ';
        ado = DataController.ReadData(queryString);
        //Assert for errors
        System.assert(COM_Utils.isNotEmpty(ado.Errors));
        
        queryString = ' SELECT ID, NAME FROM INVALID_SOBJ ';
        ado = DataController.ReadData(queryString);
        //Assert for errors
        System.assert(COM_Utils.isNotEmpty(ado.Errors));
        
        queryString = ' SELECT ID, NAME FROM Account ';
        ado = DataController.ReadData(queryString);
        //Assert for no errors and no data returned
        System.assert(COM_Utils.isEmpty(ado.Errors));
        System.assert(COM_Utils.isEmpty(ado.Records));
        
        Account acc = new Account(Name='Acme Corp', AccountNumber='1', Sic='1');
        insert acc;
        queryString = ' SELECT ID, NAME FROM Account ';
        ado = DataController.ReadData(queryString);
        //Assert for no errors and data returned
        System.assert(COM_Utils.isEmpty(ado.Errors));
        System.assert(COM_Utils.isNotEmpty(ado.Records));
        System.assertEquals(1,ado.Records.size());
        
        acc = new Account(Name='Acme Corp', AccountNumber='1', Sic='1');//No. of fields/columns selected = 3
        insert acc;
        ado = DataController.ReadData(getValidQueryDesc(acc));
        //Assert for no errors and data returned
        System.assert(COM_Utils.isEmpty(ado.Errors));
        System.assert(COM_Utils.isNotEmpty(ado.Records));
        System.assertEquals(1,ado.Records.size());
        System.assert(COM_Utils.isNotEmpty(ado.SourceObject));
        System.assert(COM_Utils.isNotEmpty(ado.Response));
        System.assert(ado.Response.size() >= 3);
    }
    
    private static ActionDataObject getValidQueryDesc(SObject sObj) {
    	ActionDataObject queryDefinition = new ActionDataObject();
    	queryDefinition.SourceObject = COM_Utils.getSObjectTypeName(sObj);
    	
    	List<ActionDataRecord> records = new List<ActionDataRecord>(); 
    	Map<String, String> newData = new Map<String, String>();
    	Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(COM_Utils.getSObjectTypeName(sObj)).getDescribe().fields.getMap();
 		//Complete list of sObject fields 
 		Set<String> objectFieldNames = objectFields.keySet();
 		Map<String,Object> checkFieldsMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sObj));
		//List of fields queried
		Set<String> checkFields = checkFieldsMap.keySet();
		//Get only the queried fields
		objectFieldNames = COM_Utils.getValidFields(objectFieldNames,new List<String>(checkFields));
		for(String fieldName : objectFieldNames) {
	    	newData.put(fieldName,String.valueOf(sObj.get(fieldName)));
		}
		
		Map<String, String> response = new Map<String, String>();
		Integer count = 0;
		for(String fieldName : objectFieldNames) {
	    	response.put('Field['+count+']',fieldName);
	    	count++;
		}
    	
    	ActionDataRecord record = new ActionDataRecord();
    	record.NewData = newData;
    	records.add(record);
    	
    	queryDefinition.Response = response;
    	queryDefinition.Records = records;
    	
    	return queryDefinition;
    }
}