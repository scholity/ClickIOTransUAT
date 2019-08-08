/*****************************************************************************************************
Class    :  WebToCasePageController
Developer:  Mickey Murphy, Blue Wolf Group LLC
Created  :  April 23, 2013
Modified :
Objective:  This class provides methods to WebToCasePage.page.

*****************************************************************************************************/

public with sharing class WebToCasePageController
{
    //  public properties declared in alphabetical order
    public String  caseDescription   { get; set; }
    public String  caseSubject       { get; set; }
    public String  email             { get; set; }
    public String  firstName         { get; set; }
    public String  lastName          { get; set; }
    public String  mailingPostalCode { get; set; }
    public Boolean renderContinue    { get; private set; }
    public Boolean renderCreateCase  { get; private set; }

    //  public methods listed in alphabetical order
    public PageReference validateCaseInput ()
    {
        PageReference pageReference = null;

        if ( isValidCaseInput () )
        {
            renderContinue   = false;      
            renderCreateCase = true;

        }

        return pageReference;

    }   //  validateCaseInput ()

    public WebToCasePageController ()
    {
        renderContinue = true;

    }   //  constructor

    //  private methods listed in alphabetical order
    private void addError (String sMessage)
    {
        ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.ERROR, sMessage));
        System.debug (Logginglevel.ERROR, sMessage);

    }   //  addError ()

    private static Boolean isValidEmail ( String email )
    {
        final String emailRegex   = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        final String gmailRegex   = '^([^+]+)[+]+([^+]+)@gmail.com';
        Pattern      emailPattern = Pattern.compile (emailRegex);
        Pattern      gmailPattern = Pattern.compile (gmailRegex);
        Matcher      emailMatcher = emailPattern.matcher (email);
        Matcher      gmailMatcher = gmailPattern.matcher (email);
        Boolean      isValid      = emailMatcher.matches ();

        //   validate googlemail.com "+" addresses
        if ( ! isValid )
            isValid = gmailMatcher.matches ();

        return isValid;

    }   //  isValidEmail ()

    private Boolean isValidCaseInput ()
    {
        Boolean isValid = true;

        if ( String.isBlank (firstName) )
        {
            addError ('"First Name" is a required field.  Please enter a value for this field.');
            isValid = false;

        }   //  [First Name] is null

        if ( String.isBlank (lastName) )
        {
            addError ('"Last Name" is a required field.  Please enter a value for this field.');            
            isValid = false;

        }   //  [Last Name] is null

        if ( String.isBlank (mailingPostalCode) )
        {
            addError ('"Mailing Postal Code" is a required field.  Please enter a value for this field.');            
            isValid = false;

        }   //  [Mailing Zip] is null

        if ( String.isBlank (email) )
        {
            addError ('"Email" is a required field.  Please enter a value for this field.');            
            isValid = false;

        }

        else if ( ! isValidEmail (email) )
        {
            addError ('"Email" format is invalid.  Please enter a valid email address.');            
            isValid = false;

        }   //  [Email] is null

        if ( String.isBlank (caseSubject) )
        {
            addError ('"Case Subject" is a required field.  Please enter a value for this field.');            
            isValid = false;

        }   //  [Mailing Zip] is null

        if ( String.isBlank (caseDescription) )
        {
            addError ('"Case Description" is a required field.  Please enter a value for this field.');            
            isValid = false;

        }

        return isValid;     

    }   //  isValidCaseInput ()

}