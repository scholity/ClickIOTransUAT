<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_SFDC_Admins_of_Logged_Exception</fullName>
        <description>Notify SFDC Admins of Logged Exception</description>
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
        <template>SFDC_Administration/Notify_Admins_of_Logged_Exception</template>
    </alerts>
    <rules>
        <fullName>Notify Admins of Logged Exception</fullName>
        <actions>
            <name>Notify_SFDC_Admins_of_Logged_Exception</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify SFDC admins anytime a custom exception has been logged.</description>
        <formula>Name != &quot;&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
