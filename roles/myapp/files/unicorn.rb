root = '/var/www/myapp'

worker_processes 3
user 'app', 'web'
preload_app true
timeout 30

listen "#{root}/shared/sockets/unicorn.sock", backlog: 64
pid "#{root}/shared/pids/unicorn.pid"
working_directory "#{root}/application"
stdout_path "#{root}/shared/log/unicorn.log"
stderr_path "#{root}/shared/log/unicorn_error.log"

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |master, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  old_pid = "#{master.pid}.oldbin"
  if File.exists?(old_pid) and (master.pid != old_pid)
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |master, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
