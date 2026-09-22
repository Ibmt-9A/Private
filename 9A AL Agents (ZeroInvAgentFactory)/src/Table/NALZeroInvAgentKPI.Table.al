// KPI data shown when hovering over the NAL Zero Inventory Agent icon.
table 50103 NALZeroInvAgentKPI
{
    Access = Internal;
    Caption = 'NAL Zero Inventory Agent KPI';
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;
    DataPerCompany = false;

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            ToolTip = 'Specifies the unique identifier for the agent user.';
            DataClassification = EndUserPseudonymousIdentifiers;
            Editable = false;
        }
        field(10; ItemsBlockedCount; Integer)
        {
            Caption = 'Items Blocked';
            ToolTip = 'Specifies the number of items currently blocked because their inventory is 0.';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "User Security ID")
        {
            Clustered = true;
        }
    }
}
