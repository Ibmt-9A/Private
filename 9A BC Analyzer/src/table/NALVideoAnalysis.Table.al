table 51001 NALVideoAnalysis
{
    Caption = 'Video Analysis';
    DataClassification = CustomerContent;
    LookupPageId = NALVideoAnalysisList;
    DrillDownPageId = NALVideoAnalysisList;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; FileName; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(4; VideoData; Blob)
        {
            Caption = 'Video Data';
            DataClassification = CustomerContent;
        }
        field(5; Status; Enum NALVideoAnalysisStatus)
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(6; AnalysisDate; DateTime)
        {
            Caption = 'Analysis Date/Time';
            DataClassification = SystemMetadata;
        }
        field(7; ErrorMessage; Text[2048])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(8; VideoSizeKB; Integer)
        {
            Caption = 'Video Size (KB)';
            DataClassification = SystemMetadata;
        }
        field(9; CreatedBy; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(10; CreatedAt; DateTime)
        {
            Caption = 'Created At';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(11; PromptTokens; Integer)
        {
            Caption = 'Prompt Tokens Used';
            DataClassification = SystemMetadata;
        }
        field(12; CompletionTokens; Integer)
        {
            Caption = 'Completion Tokens Used';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; EntryNo)
        {
            Clustered = true;
        }
        key(Status; Status) { }
    }

    trigger OnInsert()
    begin
        CreatedBy := CopyStr(UserId(), 1, MaxStrLen(CreatedBy));
        CreatedAt := CurrentDateTime();
    end;

    procedure HasVideo(): Boolean
    begin
        Rec.CalcFields(VideoData);
        exit(Rec.VideoData.HasValue());
    end;
}
