permissionset 50100 NALSOAgent
{
    Caption = 'NAL Sales Order Agent';
    Assignable = true;
    // Tasks are executed with the intersection of the user's permissions and the agent's permissions.
    IncludedPermissionSets = "D365 SALES DOC, EDIT", "D365 BASIC";
}
