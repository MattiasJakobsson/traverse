deps:
	mix deps.get

compile: deps
	mix compile
	
run: compile
	iex -S mix

install:
	sudo apt-get install -y elixir
	sudo apt-get install -y erlang-inets
	sudo apt-get install -y erlang-dev
	sudo apt-get install -y erlang-parsetools
	
clean:
	mix clean; rm -fr _build _rel _images