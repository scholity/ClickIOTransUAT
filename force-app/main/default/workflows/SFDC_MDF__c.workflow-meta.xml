<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Grant_Approval_Request</fullName>
        <description>Grant Approval Request</description>
        <protected>false</protected>
        <recipients>
            <recipient>NAT_Approval_Request</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PHSS_Sales_Internal_Emails/Grant_Approval_Request</template>
    </alerts>
    <alerts>
        <fullName>Grant_Claim_Escalation_Approval</fullName>
        <ccEmails>snehra@salesforce.com</ccEmails>
        <description>Grant Claim Escalation Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>rosiris.guerra@redcross.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PHSS_Sales_Internal_Emails/Grant_Approval_Request</template>
    </alerts>
    <alerts>
        <fullName>fundrequestapprovedsubmitternotification</fullName>
        <description>Fund Request Approved - Submitter Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDFEmailTemplates/FundRequestApproved</template>
    </alerts>
    <alerts>
        <fullName>fundrequestrejectedsubmitternotification</fullName>
        <description>Fund Request Rejected - Submitter Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDFEmailTemplates/FundRequestRejected</template>
    </alerts>
    <alerts>
        <fullName>fundrequestsubmittedacknowledgment</fullName>
        <description>Fund Request Submitted - Acknowledgment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDFEmailTemplates/FundRequestSubmitterAcknowledgment</template>
    </alerts>
    <fieldUpdates>
        <fullName>Grant_Request_Approved</fullName>
        <description>Update the Checkbox for Grant Request Approval</description>
        <field>Approved__c</field>
        <literalValue>1</literalValue>
        <name>Grant Request Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>nullclaimdeadlinedate</fullName>
        <description>Good to reset this at the start of an approval process.</description>
        <field>Claim_Deadline_Date__c</field>
        <name>Null Claim Deadline Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>setfundclaimdeadlinedate</fullName>
        <field>Claim_Deadline_Date__c</field>
        <formula>TODAY() + 60</formula>
        <name>Set Fund Claim Deadline Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updateapprovedtofalse</fullName>
        <description>Used to trigger a budget recalculation. Used in place of driving the recalculation from an approval status text based value</description>
        <field>Approved__c</field>
        <literalValue>0</literalValue>
        <name>Update Approved to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updateapprovedtotrue</fullName>
        <description>Used in favor of the approval status field so that the Apex trigger which will fire using this True/ False field rather than a text based value in the approval status page</description>
        <field>Approved__c</field>
        <literalValue>1</literalValue>
        <name>Update Approved to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatefundrequestapproveddate</fullName>
        <field>Approved_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Fund Request Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatefundrequeststatustoapproved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Fund Request Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatefundrequeststatustodraft</fullName>
        <field>Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Update Fund Request Status To Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatefundrequeststatustoinprocess</fullName>
        <field>Status__c</field>
        <literalValue>In Process</literalValue>
        <name>Update Fund Request Status To In Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatefundrequeststatustorejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Fund Request Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatefundrequeststatustosubmitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Update Fund Request Status To Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
