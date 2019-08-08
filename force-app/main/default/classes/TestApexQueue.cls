/*****************************************************************************************************
 
Class    :  TestApexQueue
Developer:  Krishna Kollu, Joo Kang, Blue Wolf Group LLC
Created  :  April 30, 2014
Modified :  May 15, 2014
Objective:  This class tests ApexQueue
 
*****************************************************************************************************/ 
@isTest
private class TestApexQueue {
	
	static testMethod void testFlow() {
		List<Case> testRecords = TestUtil.createCases(5, false);
		UnitTest.addData(testRecords).tag('Test Records');
		UnitTest.get('Test Records').dummyInsert();
		ApexQueue Q = new ApexQueue(testRecords.clone());
		System.assertEquals(5, Q.size(), 
			'An ApexQueue constructed with a list of 5 records should return 5 on call to size()');
		System.assertEquals(Q.size(), Q.getList().size(), 'getList() test: size of list should be the same in both method');
		System.assertEquals(testRecords, Q.getList(), 'getList() test: should return the queue in the right order');
		for (Integer i=0; i<5; i++) 
			Q.pop();
		System.assertEquals(0, Q.size(),
			'Popping out all 5 elements should return 0 on call to size()');
		System.assert(Q.isEmpty(),
			'Since there are no more elements in the Queue, isEmpty() should return true');
		System.assertEquals(Q.size(), Q.getList().size(), 'getList() test: size of list should be both 0 in both methods');
		System.assertEquals(null, Q.peek(), 'Asserting null value is returned for call to an empty queue');
		System.assertEquals(null, Q.back(), 'Asserting null value is returned for call to an empty queue');
		System.assertEquals(null, Q.pop(), 'Asserting null value is returned for call to an empty queue');

		for (Integer i=0; i<5; i++) 
			Q.push(testRecords[i]);
		System.assertEquals(Q.size(), Q.getList().size(), 'getList() test: size of list should be the same in both method');
		System.assertEquals(testRecords, Q.getList(), 'getList() test: should return the queue in the right order');
		List<Case> actualRecords = new List<Case>();
		for (Integer i=0; i<5; i++) {
			System.assertEquals(testRecords[i].id, Q.peek().id,
				'After every pop of an element, the peek value should return something different');
			System.assertEquals(testRecords[4].id, Q.back().id,
				'Every time an element is popped, except for when the queue is empty, back should return the last element');
			System.assertEquals(5-i, Q.getList().size(), 'getList() test: size of list should decrease by one');
			actualRecords.add((Case)Q.pop());
		}
		System.assertEquals(0, Q.getList().size(), 'getList() test: size of list should be 0');
		for (Integer i=0; i<5; i++)
			System.assertEquals(testRecords[i].id, actualRecords[i].id,
				'A list of records that are pushed in at once and popped out at once should be the same');
	}
	
	static testMethod void testEmptyConstructor() {
		List<Case> noRecords = new List<Case>();
		ApexQueue Q = new ApexQueue(noRecords);
		System.assertEquals(0, Q.size(), 
			'An ApexQueue constructed with a list of 0 records should return 0 on call to size()');
		System.assert(Q.isEmpty(),
			'Since the Queue was constructed with an empty list of cases, isEmpty() should return true');
	}	
}