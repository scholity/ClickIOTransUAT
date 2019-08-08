<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>fundclaimapprovedsubmitternotification</fullName>
        <description>Fund Claim Approved - Submitter Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDFEmailTemplates/FundClaimApproved</template>
    </alerts>
    <alerts>
        <fullName>fundclaimrejectedsubmitternotification</fullName>
        <description>Fund Claim Rejected - Submitter Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDFEmailTemplates/FundClaimRejected</template>
    </alerts>
    <alerts>
        <fullName>fundclaimsubmittedacknowledgment</fullName>
        <description>Fund Claim Submitted - Acknowledgment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDFEmailTemplates/FundClaimAcknowledged</template>
    </alerts>
    <alerts>
        <fullName>mdfclaimsubmitted</fullName>
        <description>MDF Claim Submitted</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDFEmailTemplates/FundClaimAcknowledged</template>
    </alerts>
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
        <fullName>updatefundclaimapproveddate</fullName>
        <field>Approved_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Fund Claim Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatefundclaimstatustoapproved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Fund Claim Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatefundclaimstatustodraft</fullName>
        <field>Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Update Fund Claim Status To Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatefundclaimstatustorejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Fund Claim Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatefundclaimstatustosubmitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Update Fund Claim Status To Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updateperformanceverifiedtotrue</fullName>
        <field>Performance_Verified__c</field>
        <literalValue>1</literalValue>
        <name>Update Performance Verified To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Grant Claim Approved</fullName>
        <actions>
            <name>updatefundclaimapproveddate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SFDC_MDF_Claim__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Update fields when Grant Claim is Approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Program Area</fullName>
        <active>false</active>
        <criteriaItems>
            <field>SFDC_MDF_Claim__c.Budget_Program_area__c</field>
            <operation>equals</operation>
            <value>NAT</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Program Field</fullName>
        <active>false</active>
        <criteriaItems>
            <field>SFDC_MDF_Claim__c.Budget_Program_area__c</field>
            <operation>equals</operation>
            <value>NAT</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
