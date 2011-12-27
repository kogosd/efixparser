LIBDIR=`erl -eval 'io:format("~s~n", [code:lib_dir()])' -s init stop -noshell`
VERSION=0.0.1

all:
		mkdir -p ebin/
		(cd src;$(MAKE))

clean:
		(cd src;$(MAKE) clean)
		rm -rf erl_crash.dump *.beam *.hrl 

run: all
		erl -noshell +v -pa ebin  -s efixparser -s init stop

