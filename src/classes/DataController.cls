/**
* @author Sukrut Wagh
* @date 11/17/2015
* @description 	Interacts with the Salesforce data layer to create, retrieve, update, and delete
*				records.  Consumers communicate with the DataController using ActionDataObjects.  
*				All CRUD operations are performed in the context of the current Salesforce organization.
*				IMPORTANT: The caller should first inspect for any ActionDataObject.Errors on the returned data.
*/
public class DataController {
    
	private static final COM_Logger LOGGER = new COM_Logger('DataController');
	
    /**
	* @description	Upserts a record into Salesforce.
	* @author	Sukrut Wagh
	* @version	11/17/2015
	* @param	ActionDataObject sourceData data to be saved
	* @return	ActionDataObject containing data from the newly created or updated record.
	*/
    public static ActionDataObject SaveData(final ActionDataObject sourceData) {
    	String methodName = 'SaveData';
		LOGGER.entry(methodName);
		LOGGER.fine('sourceData:'+sourceData);
        ActionDataObject result = null;
		List<String> errors = new List<String>();
    	try {
    		if(COM_Utils.isNotEmpty(sourceData)) {
    			
    		}
    	} catch (Exception ex) {
    		LOGGER.error(ex);
            errors.add(LOGGER.getLastLogMsg());
    	} finally {
    		result = setErrors(errors,result);
    	}
        LOGGER.fine('result:'+result);
    	LOGGER.exit(methodName);
    	return result;
    }
    
    /**
	* @description	Fetches the Salesforce record
	* @author	Sukrut Wagh
	* @version	11/17/2015
	* @param	ActionDataObject queryDefinition
	* @return	ActionDataObject 
	*/
    public static ActionDataObject ReadData(final ActionDataObject queryDefinition) {
    	String methodName = 'ReadData(queryDefinition)';
		LOGGER.entry(methodName);
		LOGGER.fine('queryDefinition:'+queryDefinition);
    	ActionDataObject result = null;
        List<String> errors = new List<String>();
    	try {
    		String queryString = '';
    		result = ReadData(queryString);
    	} catch (Exception ex) {
    		LOGGER.error(ex);
            errors.add(LOGGER.getLastLogMsg());
    	} finally {
    		result = setErrors(errors,result);
    	}
    	LOGGER.exit(methodName);
    	return result;
    }
    
    /**
	* @description	Fetches the Salesforce record. Record fetch limit is set to 10
	*				TODO: Add SOSL support, populate ActionDataRecord.ChildDataObjects
	* @author	Sukrut Wagh
	* @version	11/17/2015
	* @param	ActionDataObject queryString - Supports SOQL queries
	* @return	ActionDataObject 
	*/
    public static ActionDataObject ReadData(String queryString) {
    	String methodName = 'ReadData(queryString)';
		LOGGER.entry(methodName);
		LOGGER.fine('queryString:'+queryString);
    	ActionDataObject result = null;
        List<sObject> queryResult = null;
        List<String> errors = new List<String>();
        //TODO: Externalize to custom settings
        Integer queryLimit = 10;
    	try {
            if(COM_Utils.isNotEmpty(queryString)) {
            	//TODO: Don't have time to play with String parsing for the assessment. Assume the quertString doen't come with LIMIT
            	queryString += ' LIMIT '+queryLimit;
    			//Check if SOQL or SOSL. No need to verify the syntax as appropriate exception will be raised
                if(queryString.containsIgnoreCase('SELECT')) {//SOQL
                    queryResult = Database.query(queryString);
                } else if(queryString.containsIgnoreCase('FIND')) {//SOSL
                    /*
                     * Search.find or query? 
                     * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_search.htm
                     */
                    if(queryString.containsIgnoreCase('WITH SNIPPET')) {
                        //queryResult = Search.find(queryString);
                    } else {
                    	//queryResult = Search.query(queryString);    
                    }
                    LOGGER.warn('SOSL queries are not supported:'+queryString);
                    errors.add(LOGGER.getLastLogMsg());
                } else {
                    LOGGER.warn('Not a valid Salesforce query:'+queryString);
            		errors.add(LOGGER.getLastLogMsg());
                }
                result = getActionDataObject(queryResult);
            } else {
                LOGGER.warn('Not a valid Salesforce query:'+queryString);
            	errors.add(LOGGER.getLastLogMsg());
            }
    	} catch (Exception ex) {
    		LOGGER.error(ex);
            errors.add(LOGGER.getLastLogMsg());
    	} finally {
    		result = setErrors(errors,result);
    	}
    	LOGGER.fine('result:'+result);
    	LOGGER.exit(methodName);
    	return result;
    }
    
    public static ActionDataObject getActionDataObject(final List<sObject> sObjList) {
    	ActionDataObject result = null;
    	if(COM_Utils.isNotEmpty(sObjList) && COM_Utils.isNotEmpty(sObjList[0])) {
	    	result = new ActionDataObject();
	    	//Note: list.getSObjectType() is buggy. Always returning null
    		result.SourceObject = COM_Utils.getSObjectTypeName(sObjList[0]);
    		result.Records = getActionDataRecords(sObjList);
    	}
    	return result;
    }
    
    /**
	* @description	Fetches the Salesforce record. Record fetch limit is set to 10
	*				TODO: Populate ActionDataRecord.ChildDataObjects
	* @author	Sukrut Wagh
	* @version	11/17/2015
	* @param	List<sObject> sObjList
	* @return 	List<ActionDataRecord>
	*/
    public static List<ActionDataRecord> getActionDataRecords(final List<sObject> sObjList) {
    	List<ActionDataRecord> result = null;
    	if(COM_Utils.isNotEmpty(sObjList)) {
	    	result = new List<ActionDataRecord>();
	    	ActionDataRecord record = null;
	    	Map<String, String> dataMap = null;
	    	for(SObject sObj: sObjList) {
	    		if(COM_Utils.isNotEmpty(sObj) && COM_Utils.isNotEmpty(sObjList[0])) {
	    			record = new ActionDataRecord();
	    			record.SourceRecordId = String.valueOf(sObj.get('Id'));
	    			dataMap = new Map<String, String>();
	    		    /*
	    			*	Note: Using Map<String,Object> dataMap = JSON.deserializeUntyped(JSON.serialize(sObj)):
	    			*			- To avoid Exception: SObject row was retrieved via SOQL without querying the requested field			
	    			*			- However, unnecessary rountrip serialize-deserialize, causing performance implications for bulky sObjects
	    			*/
	    			Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(COM_Utils.getSObjectTypeName(sObjList[0])).getDescribe().fields.getMap();
			 		//Complete list of sObject fields 
			 		Set<String> objectFieldNames = objectFields.keySet();
			 		
			 		Map<String,Object> checkFieldsMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sObj));
					//List of fields queried
					Set<String> checkFields = checkFieldsMap.keySet();
					//Get only the queried fields
					objectFieldNames = COM_Utils.getValidFields(objectFieldNames,new List<String>(checkFields));
					
			 		for(String fieldName: objectFieldNames) {
			 			//Not sure about the data type. Better retrieve in Object
			 			Object fieldValue = sObj.get(fieldName);
			 			if(COM_Utils.isNotEmpty(fieldValue)) {
			 				/*
			 				* 	Note: This data object would be serialized & deserialized at some point. In order to shrink the map's size, only include the fields with value
			 				*	For setting properties to null/empty/blank, you may choose a special key like 'fieldsToNull'
			 				*/
				 			dataMap.put(fieldName,String.valueOf(fieldValue));
			 			} else {
			 				//TODO: Short of time. Implement 'fieldsToNull' concept - https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_calls_concepts_core_data_objects.htm
			 			}
			 		}
	    			record.NewData = dataMap;
	    			result.add(record);
	    		}
	    	}
    	}
    	return result;
    }
    
    /**
	* @description	Deletes the data from Salesforce. TODO: Not expected in the assessment
	* @author	Sukrut Wagh
	* @version	11/17/2015
	* @param	ActionDataObject data to be deleted
	* @return	ActionDataObject result of this method
	*/
    public static ActionDataObject DeleteData(final ActionDataObject data) {
    	String methodName = 'DeleteData(data)';
		LOGGER.entry(methodName);
		LOGGER.fine('data:'+data);
    	ActionDataObject result = null;
        List<String> errors = new List<String>();
    	try {
    		//TODO
    		LOGGER.warn('TODO: Method/Operation not implemented!');
    	} catch (Exception ex) {
    		
    	} finally {
    		result = setErrors(errors,result);
    	}
    	LOGGER.exit(methodName);
    	return result;
    }
    /**
	* @description	Sets the errors in ActionDataObject
	* @author	Sukrut Wagh
	* @version	11/17/2015
	* @param	List<String> errors
	* @return	ActionDataObject 
	*/
    private static ActionDataObject setErrors(final List<String> errors, ActionDataObject obj) {
    	String methodName = 'setErrors';
		LOGGER.entry(methodName);
		LOGGER.fine('errors:'+errors);
    	if(COM_Utils.isEmpty(obj)) {
    		obj = new ActionDataObject();
    	}
    	if(COM_Utils.isNotEmpty(errors)) {
    		if(COM_Utils.isEmpty(obj.Errors)) {
    			obj.Errors = errors;
    		} else {
    			obj.Errors.addAll(errors);
    		}
    	}
    	LOGGER.exit(methodName);
    	return obj;
    }
}