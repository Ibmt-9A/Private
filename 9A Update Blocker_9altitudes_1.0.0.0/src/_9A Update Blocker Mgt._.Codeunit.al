codeunit 99999 "9A Update Blocker Mgt."
{
    Access = Internal;
    Subtype = Upgrade;

    #region OnCheckPreconditionsPerCompany
    trigger OnCheckPreconditionsPerCompany()
    begin
        Error('9A Update blocker is active. Please contact 9altitudes for assistance.');
    end;
#endregion OnCheckPreconditionsPerCompany
}
