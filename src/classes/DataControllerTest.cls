/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DataControllerTest {

    static testMethod void ReadDataTest() {
        String queryString = '';
        ActionDataObject ado = null;
        ado = DataController.ReadData(queryString);
        System.assert(COM_Utils.isNotEmpty(ado.Errors));
        queryString = ' Invalid query ';
        ado = DataController.ReadData(queryString);
        //Assert for errors
        System.assert(COM_Utils.isNotEmpty(ado.Errors));
        queryString = ' SELECT ID, NAME FROM Account ';
        ado = DataController.ReadData(queryString);
        //Assert for no errors and no data returned
        System.assert(COM_Utils.isEmpty(ado.Errors));
        System.assert(COM_Utils.isEmpty(ado.Records));
        Account acc = new Account(Name='Acme Corp', AccountNumber='1', Sic='1');
        insert acc;
        queryString = ' SELECT ID, NAME FROM Account ';
        ado = DataController.ReadData(queryString);
        //Assert for no errors and data returned
        System.assert(COM_Utils.isEmpty(ado.Errors));
        System.assert(COM_Utils.isNotEmpty(ado.Records));
        System.assertEquals(1,ado.Records.size());
    }
}