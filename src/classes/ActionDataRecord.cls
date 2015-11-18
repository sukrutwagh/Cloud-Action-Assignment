/**
* @author Sukrut Wagh
* @date 11/17/2015
* @description 	A data container for real data involved in a transaction.  It contains record values
*				differentiated by data state ("old" values versus "new" values.)
*/
public class ActionDataRecord {
	
	/** 
	* @description 	The unique Id of the record from which this
	*				ActionDataRecord was built. 
	*/
	public String SourceRecordId{get;set;}
	
	/** 
	* @description 	The unique Id of the record that has been created
	*				in a target connector record using this 
	*				ActionDataRecord as source data.
	*/
	public String TargetRecordId{get;set;}
	
	/** 
	* @description 	Represents record's current state data
	*/
	public Map<String, String> NewData{get;set;}
	
	/** 
	* @description 	Represents record's current state data. Not all systems
	*				support previous state data.
	*/
	public Map<String, String> OldData{get;set;}
	
	/** 
	* @description 	records related as children to the current ActionDataRecord.
	*/
	public List<ActionDataRecord> ChildDataObjects{get;set;}
	
    
}