// Registers the NAL Zero Inventory Agent as a selectable agent type.
enumextension 50112 NALZeroInvAgentMetaProvExt extends "Agent Metadata Provider"
{
    value(50112; "NAL Zero Inventory Agent")
    {
        Caption = 'NAL Zero Inventory Agent';
        Implementation = IAgentFactory = NALZeroInvAgentFactory, IAgentMetadata = NALZeroInvAgentMetadata, IAgentTaskExecution = NALZeroInvAgentTaskExecution;
    }
}
