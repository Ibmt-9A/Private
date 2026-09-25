permissionset 50100 NALSOAgent
{
    Caption = 'NAL Sales Order Agent';
    Assignable = true;
    // Tasks are executed with the intersection of the user's permissions and the agent's permissions - the interactive
    // user's own permission set (e.g. SUPER) does not widen this. Sales line availability checks indirectly read Job
    // Planning Line, Transfer Line and Prod. Order Line/Component (supply from Jobs/Warehouse/Manufacturing) even
    // when those modules aren't otherwise used - this does not create any of those documents, just reads them.
    // Creating a sales quote also logs a CRM interaction, requiring read access to the Interaction Log/Group tables.
    // Opening the Sales Quotes list triggers several of Continia Document Output's hooks; "CDO-ALL" alone doesn't
    // cover every table it reads, so use "CDO-SUPER" (their broadest set) instead. Both are marked for removal in
    // favor of internal replacements Continia doesn't expose, so the obsolete-reference warning is suppressed.
    // Continia Payment Management has no public permission set at all (all CPM365/CPM sets are Internal), so its
    // tables must be granted individually below instead.
#pragma warning disable AL0432
    IncludedPermissionSets = "D365 SALES DOC, EDIT", "D365 BASIC", "CDO-SUPER";
#pragma warning restore AL0432
    Permissions = tabledata "Job Planning Line" = R,
                  tabledata "Transfer Line" = R,
                  tabledata "Interaction Log Entry" = R,
                  tabledata "Interaction Group" = R,
                  tabledata "Prod. Order Line" = R,
                  tabledata "Prod. Order Component" = R,
                  tabledata "CDO Send Actions Visibility" = R,
                  tabledata "CPM Payment 365 Setup" = R;
}
