package catalog

import (
	"os"

	"gopkg.in/yaml.v3"
)

type MetadataLoader interface {
	LoadExperiences(path string) ([]Experience, error)
	LoadExecutionIntents(path string) ([]ExecutionIntent, error)
}

type yamlMetadataLoader struct{}

func NewMetadataLoader() MetadataLoader {
	return &yamlMetadataLoader{}
}

func (l *yamlMetadataLoader) LoadExperiences(path string) ([]Experience, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var wrapper struct {
		Experiences []Experience `yaml:"experiences"`
	}

	if err := yaml.Unmarshal(data, &wrapper); err != nil {
		return nil, err
	}

	return wrapper.Experiences, nil
}

func (l *yamlMetadataLoader) LoadExecutionIntents(path string) ([]ExecutionIntent, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var wrapper struct {
		Intents []ExecutionIntent `yaml:"intents"`
	}

	if err := yaml.Unmarshal(data, &wrapper); err != nil {
		return nil, err
	}

	return wrapper.Intents, nil
}
