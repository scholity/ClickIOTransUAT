<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>COH_Handed_Off_Status</fullName>
        <description>This field update will add the case status to the COH record when it is created.</description>
        <field>Recieved_Case_status__c</field>
        <formula>Text(Case__r.Status)</formula>
        <name>COH - Handed Off Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>COH_Received_Status</fullName>
        <description>This field update populates the case owner history handed off status field with the status of the case at the time it is handed off.</description>
        <field>Hand_Off_Status__c</field>
        <formula>TEXT( Case__r.Status )</formula>
        <name>COH - Received Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>COH - Handed Off Status</fullName>
        <actions>
            <name>COH_Received_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case_Owner_History__c.Received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Owner_History__c.Handed_Off__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow will update the COH object with the status a case was in during the time the COH was updated with a Handed off Date/Time.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>COH - Received Status</fullName>
        <actions>
            <name>COH_Handed_Off_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case_Owner_History__c.Received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case_Owner_History__c.Handed_Off__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>This workflow will update the COH object with the status a case was in during the time the COH was created and that owner received that case.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
