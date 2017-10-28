# RedixStage

Redix Stage combines Redix with an optimized GenStage pipeline in the case you have a high load of write-based redis commands.

The app creates as many buffers (GenStage producers) as your erlang VM schedulers and by default 2 times more workers (GenStage consumers) that will actually execute the redis commands.

For example, if you have 4 schedulers, you'll have 4 buffers and 8 workers. Since only the workers are connected to redis, that's 8 active connections to your redis instance.

You can configure the app with your config.exs.

Available config keys:
 - `redis_url` by default redis://localhost
 - `workers_multiplier` by default 2 (2 workers per buffer)

You shouldn't use it for read-based redis commands since the flow is completly asynchronous.
You also can't use a redis pipeline due to the fact that the workers already use redis pipelines.

# How-to

```elixir
>> RedixStage.cmd(["LPUSH", "my_queue", "Hello world!"])
:ok
>> RedixStage.cmd(["SET", "foo", "bar"])
:ok
```

You can also use RedixStage.cmd/2, where the first argument is a phrase that will determine (after being hashed) which buffer your command will go to. By default, the first string of your command will be used as the phrase.

# Installation

```elixir 
{:redix_stage, github: "mee6/redix_stage"}
```
