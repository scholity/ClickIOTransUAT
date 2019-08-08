<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Empty_Schedule_Date</fullName>
        <field>Scheduled_Date_Time__c</field>
        <name>Empty Schedule Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fire_Flow</fullName>
        <field>Fire_Flow__c</field>
        <literalValue>1</literalValue>
        <name>Fire Flow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Next_Scheduled_Date_Time</fullName>
        <description>Update the value of the Next Scheduled Date and Time</description>
        <field>Next_Scheduled_Date_Time__c</field>
        <formula>CASE( MOD( DATEVALUE( Scheduled_Date_Time__c ) - DATE( 1900, 1, 7 ), 7 ),
0, Scheduled_Date_Time__c + 1 +  Percent_of_Day__c ,
1, Scheduled_Date_Time__c + 0 + Percent_of_Day__c ,
2, Scheduled_Date_Time__c + 0 + Percent_of_Day__c ,
3, Scheduled_Date_Time__c + 0 + Percent_of_Day__c ,
4, Scheduled_Date_Time__c + 0 + Percent_of_Day__c ,
5, Scheduled_Date_Time__c + 0 + Percent_of_Day__c ,
6, Scheduled_Date_Time__c + 0 + Percent_of_Day__c ,
Scheduled_Date_Time__c + Percent_of_Day__c 
)</formula>
        <name>Update Next Scheduled Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Schedule_Date</fullName>
        <description>Update the Scheduled Date/Time field with the Next Scheduled Date/Time Value</description>
        <field>Scheduled_Date_Time__c</field>
        <formula>Next_Scheduled_Date_Time__c</formula>
        <name>Update Schedule Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Scheduled Flow</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Process_Scheduling__c.Scheduled_Date_Time__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Process_Scheduling__c.Fire_Flow__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Process_Scheduling__c.Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Initial Schedule Controller</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Empty_Schedule_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Fire_Flow</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Process_Scheduling__c.Scheduled_Date_Time__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update the Next Schedule</fullName>
        <actions>
            <name>Update_Next_Scheduled_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the value of Next Scheduled Date/Time</description>
        <formula>ISCHANGED( Scheduled_Date_Time__c  ) &amp;&amp; NOT ( ISBLANK( Scheduled_Date_Time__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update to Scheduled Date%2FTime</fullName>
        <actions>
            <name>Update_Schedule_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Process_Scheduling__c.Fire_Flow__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update the Scheduled Date/Time field with the Next Scheduled Date/Time value</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
