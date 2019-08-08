/*****************************************************************************************************
 
Class    :  ApexQueue
Developer:  Krishna Kollu, Joo Kang, Blue Wolf Group LLC
Created  :  April 30, 2014
Modified :  May 15, 2014
Objective:  This is a queue data structure
 
*****************************************************************************************************/ 
public with sharing class ApexQueue {

	List<SObject> records;

	public ApexQueue() {
		records = new List<SObject>();
	}

	/*
	 * Construct an apex queue for a given list. Any push/pops on the queue will affect the list
	 */
	public ApexQueue(List<SObject> records) {
		this.records = records;
	}

	/*
	 * Push the specified record into the back of the queue
	 */
	public void push(SObject record)
	{
		records.add(record);
	}

	/*
	 * Return the first record in the queue and remove it from the queue
	 * If there are no records in the queue, then null will be returned.
	 */
	public SObject pop()
	{
		if(isEmpty())
			return null;
		else
		{
			SObject objectToReturn = records[0];
			records.remove(0);
			return objectToReturn;
		}
	}

	/*
	 * Return the first record in the queue.
	 * If there are no records in the queue, then null will be returned.
	 */
	public SObject peek()
	{
		if(isEmpty())
			return null;
		else
			return records[0];
	}

	/*
	 * Return the last record in the queue.
	 * If there are no records in the queue, then null will be returned.
	 */
	public SObject back()
	{
		if(isEmpty())
			return null;
		else
			return records[records.size()-1];
	}

	/*
	 * Returns true iff the queue is empty
	 */
	public Boolean isEmpty()
	{
		return records.isEmpty();
	}

	/*
	 * Returns size of queue
	 */
	public Integer size()
	{
		return records.size();
	}

	/*
	 * Return the records in the queue
	 */
	public List<SObject> getList()
	{
		return records;
	}
}