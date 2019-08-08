<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>BGST_Activity_Type</fullName>
        <field>BGST_Activity_Type__c</field>
        <literalValue>AED</literalValue>
        <name>BGST Activity Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Lead_Owner_to_BGST_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>BGST_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Lead Owner to BGST Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_AQ_mgrs</fullName>
        <field>OwnerId</field>
        <lookupValue>AQ_Managers</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to AQ mgrs</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Land_Based_Training</fullName>
        <description>Routes Land Based training LTP Leads to BGST queue</description>
        <field>OwnerId</field>
        <lookupValue>BGST_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Land Based Training</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Origin</fullName>
        <field>BGST_Lead_Source__c</field>
        <literalValue>Marketing</literalValue>
        <name>Lead Origin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MALatitude_c_Purge</fullName>
        <field>MALatitude__c</field>
        <name>Lead.MALatitude_c_Purge</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MALongitude_c_Purge</fullName>
        <field>MALongitude__c</field>
        <name>Lead.MALongitude_c_Purge</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RCO_LTP_Application_Land</fullName>
        <field>BGST_Activity_Type__c</field>
        <literalValue>LTP</literalValue>
        <name>RCO LTP Application - Land</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AED Offers</fullName>
        <actions>
            <name>BGST_Activity_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Land_Based_Training</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Lead_Origin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Landing_Page__c</field>
            <operation>equals</operation>
            <value>https://www.redcross.org/take-a-class/aed-offers</value>
        </criteriaItems>
        <description>•	BGST Activity Type = AED
•	Lead Origin = Marketing</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BGST Lead Referral Routing</fullName>
        <actions>
            <name>Change_Lead_Owner_to_BGST_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.BGST_Lead_Source__c</field>
            <operation>equals</operation>
            <value>After-Hours Transfer Lead Form</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Landing_Page__c</field>
            <operation>equals</operation>
            <value>https://www.redcross.org/take-a-class/bgst-form</value>
        </criteriaItems>
        <description>Created temporary to route BGST Referral leads to BGST queue. This should deactivate/deleted after form works as Web-to-Lead instead of JOTForm.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RCO LTP Application - Land</fullName>
        <actions>
            <name>Land_Based_Training</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RCO_LTP_Application_Land</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Landing_Page__c</field>
            <operation>contains</operation>
            <value>org/take-a-class/licensed-training-authorized-providers</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Primary_Product__c</field>
            <operation>notContain</operation>
            <value>water based</value>
        </criteriaItems>
        <description>Routes the coming LTP applications to Queues</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RCO LTP Application - Water</fullName>
        <actions>
            <name>Change_Lead_Owner_to_BGST_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Lead.Landing_Page__c</field>
            <operation>contains</operation>
            <value>org/take-a-class/licensed-training-authorized-providers</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Primary_Product__c</field>
            <operation>contains</operation>
            <value>water based</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Water_Based_Training__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Routes the  LTP applications to Queues</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RCO LTP Application - Water -AES</fullName>
        <actions>
            <name>Change_owner_to_AQ_mgrs</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Lead.Landing_Page__c</field>
            <operation>contains</operation>
            <value>org/take-a-class/licensed-training-authorized-providers</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Water_Based_Training__c</field>
            <operation>contains</operation>
            <value>AES</value>
        </criteriaItems>
        <description>Routes the  AES LTP applications to AQ Managers queue</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>a0Rd00000006eWiEAI_Purge</fullName>
        <actions>
            <name>MALatitude_c_Purge</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MALongitude_c_Purge</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Lead.a0Rd00000006eWiEAI_Purge</description>
        <formula>OR(ISCHANGED(Street),ISCHANGED(City),ISCHANGED(State),ISCHANGED(PostalCode),ISCHANGED(Country))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
