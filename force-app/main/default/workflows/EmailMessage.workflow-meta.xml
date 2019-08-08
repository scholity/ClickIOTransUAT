<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Case_Owner_Finance_Ready_to_Close</fullName>
        <field>OwnerId</field>
        <lookupValue>Finance_COE_Ready_to_Close</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner Finance Ready to Close</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_General_Customer</fullName>
        <field>OwnerId</field>
        <lookupValue>General_Customer</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner - General Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_Instructor_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Instructor_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner - Instructor Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Record_Type_Change_Service</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Service_Cases</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Case Record Type Change - Service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Status_Update_New_Email</fullName>
        <field>Status</field>
        <literalValue>Follow Up - New Email</literalValue>
        <name>Case Status Update - New Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Follow_Up_New_Email</fullName>
        <description>Case Status Update to Follow Up New email, when a reply is send back to a case (billingadj@redcross.org)</description>
        <field>Status</field>
        <literalValue>Follow Up - New Email</literalValue>
        <name>Follow Up New Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Last_Modified_Date_Is_changed_Email</fullName>
        <field>Last_Case_Update_Time_Date__c</field>
        <formula>LastModifiedDate</formula>
        <name>Last Modified Date - Is changed - Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sales_Case_Record_Type_Change</fullName>
        <description>This changes the case records type back to an editable sales case record type</description>
        <field>RecordTypeId</field>
        <lookupValue>Sales_Case</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Sales Case Record Type Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Record_Type_to_Service_case</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Service_Cases</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Case Record Type to Service case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_fields</fullName>
        <field>Status</field>
        <literalValue>Follow Up - New Email</literalValue>
        <name>Update Status fields</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Case Queue Update - Instructor Queue</fullName>
        <actions>
            <name>Case_Owner_Instructor_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>contains</operation>
            <value>instructor</value>
        </criteriaItems>
        <description>This workflow is designed to change the owner of a case to the Instructor Queue when a new email or response email comes in with the subject containing &quot;Instructor&quot;.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Last Modified Date - Is changed - Case Email Message</fullName>
        <actions>
            <name>Last_Modified_Date_Is_changed_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to capture timestamp on last updated email message</description>
        <formula>ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Email - Update Case</fullName>
        <actions>
            <name>Case_Owner_General_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Status_Update_New_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Last_Modified_Date_Is_changed_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.FromAddress</field>
            <operation>notEqual</operation>
            <value>classes-notify@usa.redcross.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow will update the case status to Follow Up  - New Email when there is a new email awaiting reply on the case record and changes the queue to General Customer</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Email - Update Closed Sales Case</fullName>
        <actions>
            <name>Case_Owner_General_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Status_Update_New_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Last_Modified_Date_Is_changed_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sales_Case_Record_Type_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Case Read Only</value>
        </criteriaItems>
        <description>This workflow will update the case status to Follow Up  - New Email when there is a new email awaiting reply on the case record and changes the queue to General Customer</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Email - Update Closed Service Case</fullName>
        <actions>
            <name>Case_Owner_General_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Record_Type_Change_Service</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Status_Update_New_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Last_Modified_Date_Is_changed_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Service Case Read Only</value>
        </criteriaItems>
        <description>This workflow will update the case status to Follow Up  - New Email when there is a new email awaiting reply on the case record and changes the queue to General Customer</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Record Type</fullName>
        <actions>
            <name>Update_Case_Record_Type_to_Service_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_fields</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>contains</operation>
            <value>billing@</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Follow Up - New Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Read Only Invoicing</value>
        </criteriaItems>
        <description>Update Case Record Type  for Read only Invoicing Case when customer replied to closed case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>billngadjStatusUpdate</fullName>
        <actions>
            <name>Case_Owner_Finance_Ready_to_Close</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Follow_Up_New_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>equals</operation>
            <value>adjustment@redcross.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>Update a Case when a customer replies to  adjustment@redcross.org</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
