/**
* @author Sukrut Wagh
* @date 11/17/2015
* @description 	Standard communication container for sharing data between system components.
*				It contains metadata about the data source, the data destination, transaction 
*				acknowledgement requirements, and ActionDataRecord objects representing the real data.
*/
public class ActionDataObject {
	
	/** 
	* @description 	Populated with the record Id from the Event_Queue object when the instance is associated with an Event Queue record.
	*/
	public String EventQueueId{get;set;}
	
	/** 
	* @description 	Populated with the record Id from the Action_Queue object when the instance is associated with an Action Queue record.
	*/
	public String ActionQueueId{get;set;}
	
	/** 
	* @description 	Contains any error messages to be used by the recipient of the ActionDataObject.
	*/
	public List<String> Errors{get;set;}
	
	/** 
	* @description 	When the AciontDataObject is the result of an event, the Source Connection specifies the connection that created the event.
	*/
	public String SourceConnection{get;set;}
	
	/** 
	* @description 	The specific object in the Source Connection from which the event originated.
	*/
	public String SourceObject{get;set;}
	
	/** 
	* @description 	The target connector to which and event-based ActionDataObject is being sent.
	*/
	public String TargetConnection{get;set;}
	
	/** 
	* @description 	An object known to the target connector to which the ActionDataObject values will be applied.
	*/
	public String TargetObject{get;set;}
	
	/** 
	* @description 	An Id for the record that was created as a result of a TargetConnector handling an ActionDataObject.
	*/
	public String TargetParentRecordId{get;set;}
	
	/** 
	* @description 	Used by a TargetConnector adapter for special handling instructions.
	*/
	public Map<String, String> Parameters{get;set;}
	
	/** 
	* @description 	objects that contain data and child data, representing source or target data.
	*/
	public List<ActionDataRecord> Records{get;set;}
	
	/** 
	* @description 	data that should be returned from the target connection by field name ("key,") and which field in SourceObject the data should be sent to ("value.")
	*/
	public Map<String, String> Response{get;set;}
	
}