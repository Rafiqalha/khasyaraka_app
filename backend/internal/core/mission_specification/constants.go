package mission_specification

type ActivityType string

const (
	ActivityCreateFile ActivityType = "CREATE_FILE"
	ActivityRenameFile ActivityType = "RENAME_FILE"
	ActivityDeleteFile ActivityType = "DELETE_FILE"
	ActivityExecute    ActivityType = "EXECUTE"
	ActivityCompile    ActivityType = "COMPILE"
	ActivityRun        ActivityType = "RUN"
	ActivityAIAsk      ActivityType = "AI_ASK"
	ActivityPaste      ActivityType = "PASTE"
	ActivityUndo       ActivityType = "UNDO"
	ActivityCheckpoint ActivityType = "CHECKPOINT"
	ActivitySnapshot   ActivityType = "SNAPSHOT"
	ActivityComment    ActivityType = "COMMENT"
	ActivityTyping     ActivityType = "TYPING"   // Usually aggregated
	ActivityAnswer     ActivityType = "ANSWER"   // For Quiz
	ActivityQuestion   ActivityType = "QUESTION" // For Conversation
)
