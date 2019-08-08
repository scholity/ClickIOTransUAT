<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_Order_Agreement_when_Opportunity_reaches_the_Reservation_Stage</fullName>
        <description>Email Alert - Order Agreement when Opportunity reaches the Reservation Stage</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ccrz__Ecommerce/B2B_Order_Confirmation_Order_Agreement</template>
    </alerts>
    <alerts>
        <fullName>Multi_Jurisdictional_Opp_needs_attention</fullName>
        <ccEmails>PHSSAccountStructure@redcross.org</ccEmails>
        <description>Multi-Jurisdictional Opp needs attention</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/Multi_Jurisdictional</template>
    </alerts>
    <alerts>
        <fullName>Pricing_Approval_Alert</fullName>
        <description>Pricing Approval Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ivo.dimov@redcross.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sfdcautomation@redcross.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/Pricing_Approval</template>
    </alerts>
    <alerts>
        <fullName>Send_Approved_Notification_to_Opportunity_Owner</fullName>
        <description>Send AES Record Approved Notification to Opportunity Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/AES_pricing_level_approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_Pricing_Level_Approved_Notification_to_Opportunity_Owner</fullName>
        <description>Send Pricing Level Approved Notification to Opportunity Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/Pricing_Level_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_Pricing_Level_Approved_Notification_to_Opportunity_Owner_BGST</fullName>
        <description>Send Pricing Level Approved Notification to Opportunity Owner BGST</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/Pricing_Level_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Your_AED_device_Opportunity_has_been_approved</fullName>
        <description>Your AED device Opportunity has been approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Templates/AED_Device_APPROVED</template>
    </alerts>
    <alerts>
        <fullName>Your_AED_device_Opportunity_has_been_rejected</fullName>
        <description>Your AED device Opportunity has been rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Templates/AED_Device_REJECTED</template>
    </alerts>
    <fieldUpdates>
        <fullName>AED_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>AED</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AED Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AES_Record_Type</fullName>
        <description>Changes the record type to AES for Aquatics</description>
        <field>RecordTypeId</field>
        <lookupValue>Aquatics_Examiner_Service</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AES Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_for_Commision</fullName>
        <field>Approved_for_Commision_Payment__c</field>
        <literalValue>1</literalValue>
        <name>Approved for Commision</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Closed_Won_Date</fullName>
        <field>Closed_Won_Date__c</field>
        <formula>NOW()</formula>
        <name>Closed Won Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Detail_Result_1_Field_Update</fullName>
        <description>Field Update on Opportunity Details Result 1 to &quot;Being Worked&quot; when the opportunity is created from a lead</description>
        <field>Opportunity_Result_Detail_1__c</field>
        <literalValue>Being Worked</literalValue>
        <name>Opportunity Detail Result 1 Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Result_Field_Update</fullName>
        <description>Field Update on Opportunity Result to &quot;Open&quot; when the opportunity is created from a lead</description>
        <field>Opportunity_Result__c</field>
        <literalValue>Open</literalValue>
        <name>Opportunity Result Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_AES_Approval_Status_To_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Set AES Approval Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_AES_Approval_Status_To_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Set AES Approval Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_AES_Approval_Status_to_Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submit for Approval</literalValue>
        <name>Set AES Approval Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approval_Status_To_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Set Approval Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approval_Status_To_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Set Approval Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approval_Status_to_Blank</fullName>
        <field>Approval_Status__c</field>
        <name>Set Approval Status to Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approval_Status_to_Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submit for Approval</literalValue>
        <name>Set Approval Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_BGST_Approval_Status_To_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Set BGST Approval Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_BGST_Approval_Status_To_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Set BGST Approval Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_BGST_Approval_Status_to_Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submit for Approval</literalValue>
        <name>Set BGST Approval Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_date_on_Opportunity</fullName>
        <field>CloseDate</field>
        <formula>Today()</formula>
        <name>Update Closed date on Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Type_to_AED</fullName>
        <field>Type</field>
        <literalValue>AED</literalValue>
        <name>Update Type to AED</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AED Record Type</fullName>
        <actions>
            <name>AED_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Primary_Product__c</field>
            <operation>equals</operation>
            <value>AED</value>
        </criteriaItems>
        <description>When a Lead is set with Primary Product of AED, when converted, the record should be converted to AED Opportunity record type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AES Record Type</fullName>
        <actions>
            <name>AES_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Primary_Product__c</field>
            <operation>equals</operation>
            <value>AES</value>
        </criteriaItems>
        <description>When a Lead is set with Primary Product of AES, when converted, the record should be converted to AES Opportunity record type.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Check for AED Opportunity Record Type</fullName>
        <actions>
            <name>Update_Type_to_AED</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>AED</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Closed Won Date</fullName>
        <actions>
            <name>Closed_Won_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert to Create an Order Agreement</fullName>
        <actions>
            <name>Email_Alert_Order_Agreement_when_Opportunity_reaches_the_Reservation_Stage</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Reservation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Contract</value>
        </criteriaItems>
        <description>When a Sales Opportunity reaches the Reservation Stage when there is no Contract Opportunity.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Multi_Jurisdictional</fullName>
        <actions>
            <name>Multi_Jurisdictional_Opp_needs_attention</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Multi_Jurisdictional__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>Used to Alert the MJ Group of an Opp needing their attention</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Created From Lead</fullName>
        <actions>
            <name>Opportunity_Detail_Result_1_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Opportunity_Result_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Created_From_Lead__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When an oppty is created form a lead, the field Opportunity Result will automatically be set to &quot;Open&quot; and Opportunity Detail Result 1 will be set to &quot;Being Worked&quot;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Opportunity Closed Date</fullName>
        <actions>
            <name>Update_Closed_date_on_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost,Closed Won</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
