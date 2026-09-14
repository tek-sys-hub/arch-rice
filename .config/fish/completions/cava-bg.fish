# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_cava_bg_global_optspecs
	string join \n debug output= config= supervisor systemd h/help V/version
end

function __fish_cava_bg_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_cava_bg_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_cava_bg_using_subcommand
	set -l cmd (__fish_cava_bg_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c cava-bg -n "__fish_cava_bg_needs_command" -l output -d 'Filter to a specific output' -r
complete -c cava-bg -n "__fish_cava_bg_needs_command" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_needs_command" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -s V -l version -d 'Print version'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "on" -d 'Start the daemon in the background'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "off" -d 'Stop the daemon'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "kill" -d 'Alias for off'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "restart" -d 'Restart the daemon'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "status" -d 'Show daemon + output status'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "outputs" -d 'List detected runtime outputs'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "output-on" -d 'Enable one output in config'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "output-off" -d 'Disable one output in config'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "gui" -d 'Open the configuration GUI'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "__run" -d 'Internal: run in foreground'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "__supervisor" -d 'Internal: supervisor for per-output processes'
complete -c cava-bg -n "__fish_cava_bg_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand on" -l output -d 'Filter to a specific output' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand on" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand on" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand on" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand on" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand on" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand off" -l output -d 'Filter to a specific output' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand off" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand off" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand off" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand off" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand off" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand kill" -l output -d 'Filter to a specific output' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand kill" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand kill" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand kill" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand kill" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand kill" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand restart" -l output -d 'Filter to a specific output' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand restart" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand restart" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand restart" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand restart" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand restart" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand status" -l output -d 'Filter to a specific output' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand status" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand status" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand status" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand status" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand status" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand outputs" -l output -d 'Filter to a specific output' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand outputs" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand outputs" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand outputs" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand outputs" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand outputs" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-on" -l output -d 'Output name to enable' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-on" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-on" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-on" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-on" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-on" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-off" -l output -d 'Output name to disable' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-off" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-off" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-off" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-off" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand output-off" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand gui" -l output -d 'Filter to a specific output' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand gui" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand gui" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand gui" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand gui" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand gui" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __run" -l output -d 'Filter to a specific output' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __run" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __run" -l supervised
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __run" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __run" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __run" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __run" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __supervisor" -l output -d 'Filter to a specific output' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __supervisor" -l config -d 'Custom config path' -r
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __supervisor" -l debug -d 'Run in foreground debug mode'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __supervisor" -l supervisor -d 'Enable supervisor mode (per-output child processes)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __supervisor" -l systemd -d 'Run as a systemd service (logs to journald, no daemon detach)'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand __supervisor" -s h -l help -d 'Print help'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "on" -d 'Start the daemon in the background'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "off" -d 'Stop the daemon'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "kill" -d 'Alias for off'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "restart" -d 'Restart the daemon'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "status" -d 'Show daemon + output status'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "outputs" -d 'List detected runtime outputs'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "output-on" -d 'Enable one output in config'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "output-off" -d 'Disable one output in config'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "gui" -d 'Open the configuration GUI'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "__run" -d 'Internal: run in foreground'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "__supervisor" -d 'Internal: supervisor for per-output processes'
complete -c cava-bg -n "__fish_cava_bg_using_subcommand help; and not __fish_seen_subcommand_from on off kill restart status outputs output-on output-off gui __run __supervisor help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
