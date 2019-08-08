<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_Training_Event_Canceled2</fullName>
        <description>Email Alert - Training Event Canceled</description>
        <protected>false</protected>
        <recipients>
            <field>Training_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ccrz__Ecommerce/Training_Event_Cancelation</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_Training_Event_Reserved_or_Completed</fullName>
        <description>Email Alert - Training Event Reserved or Completed</description>
        <protected>false</protected>
        <recipients>
            <field>Training_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ccrz__Ecommerce/SB_Training_Event_Schedule_Confirmation</template>
    </alerts>
    <fieldUpdates>
        <fullName>OrderStatusSet</fullName>
        <field>Course_Order_Status__c</field>
        <literalValue>In Process</literalValue>
        <name>OrderStatusSet</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Email Alert when TE status %3D Completed or Reserved</fullName>
        <actions>
            <name>Email_Alert_Training_Event_Reserved_or_Completed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Training_Events__c.Scheduling_Status__c</field>
            <operation>equals</operation>
            <value>Reserved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Training_Events__c.Scheduling_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>When a Training Event Status = &quot;Completed&quot; or &quot;Reserved&quot;,  the Training Contact will receive an email.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set TE Order Status</fullName>
        <actions>
            <name>OrderStatusSet</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Training_Events__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Training Event</value>
        </criteriaItems>
        <description>For older training events, the Order Status must be set to enable dependent pick list value</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
