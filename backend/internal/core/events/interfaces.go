package events

import "context"

type Publisher interface {
	Publish(ctx context.Context, event Event) error
}

type Subscriber interface {
	Handle(ctx context.Context, event Event) error
}

type SubscriberFunc func(ctx context.Context, event Event) error

func (f SubscriberFunc) Handle(ctx context.Context, event Event) error {
	return f(ctx, event)
}

type Dispatcher interface {
	Subscribe(eventName EventName, handler Subscriber)
	Publisher
}

type Executor interface {
	Execute(ctx context.Context, handler Subscriber, event Event)
}
