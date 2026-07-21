package logger

import (
	"os"

	"github.com/rs/zerolog"
)

var log zerolog.Logger

func Init(env string) {
	if env == "development" {
		log = zerolog.New(zerolog.ConsoleWriter{Out: os.Stdout}).With().Timestamp().Logger()
	} else {
		log = zerolog.New(os.Stdout).With().Timestamp().Logger()
	}
}

func Get() zerolog.Logger {
	return log
}

func Info() *zerolog.Event {
	return log.Info()
}

func Error() *zerolog.Event {
	return log.Error()
}

func Fatal() *zerolog.Event {
	return log.Fatal()
}
