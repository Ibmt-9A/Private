permissionset 50114 NALZeroInvAgent
{
    Caption = 'NAL Zero Inventory Agent';
    Assignable = true;
    // Tasks are executed with the intersection of the user's permissions and the agent's permissions.
    IncludedPermissionSets = "D365 BASIC";
}
