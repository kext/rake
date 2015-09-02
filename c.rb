require 'rake'

class C
  @@cflags = '-Wall'
  @@ldflags = ''
  @@compiler = ENV['CC'] || 'cc'
  @@ar = ENV['AR'] || 'ar'
  @@builddir = 'build'
  @@sourcedir = 'src'
  @@libs = ''

  def C.run cmd
    r = `#{cmd}`
    raise "Error: '#{cmd}'" unless $?.success?
    return r
  end

  def C.clean
    run "rm -rf \"#{@@builddir}\""
  end

  def C.cc
    @@compiler
  end

  def C.cc= cc
    @@compiler = cc
  end

  def C.ar
    @@ar
  end

  def C.ar= ar
    @@ar = ar
  end

  def C.cflags
    @@cflags
  end

  def C.cflags= flags
    @@cflags = flags
  end

  def C.ldflags
    @@ldflags
  end

  def C.ldflags= flags
    @@ldflags = flags
  end

  def C.library name, files
    @@libs += " \"-I#{@@sourcedir}/#{name}\""
    cflags = @@cflags
    thelib = "#{@@builddir}/lib#{name}.a"
    objects = Array.new
    files.each do |f|
      type = /\.[a-zA-Z0-9]+$/.match(f).to_s
      if type == '.c' || type == '.cc' || type == '.cpp' then
        o = f.ext('.o')
        d = f.ext('.deps.rb')
        theobject = "#{@@builddir}/objects/#{name}/#{o}"
        thedeps = "#{@@builddir}/objects/#{name}/#{d}"
        thesource = "#{@@sourcedir}/#{name}/#{f}"
        objects.push theobject
        Rake::FileTask.define_task theobject => [thesource] do
          puts "[CC] #{theobject}"
          run "mkdir -p \"#{@@builddir}/objects/#{name}\""
          xxx = run "#{@@compiler} #{cflags}#{@@libs} -M \"#{thesource}\""
          xx = []
          File.open(thedeps, 'w') do |f|
            f.puts '# This file was automatically generated. Do not edit!'
            xxx.scan(/\s([^\s\\]+)/) do |x| xx.push x[0] end
            f.puts "Rake::FileTask.define_task #{theobject.dump} => #{xx}"
          end
          run "#{@@compiler} #{cflags}#{@@libs} -c -o \"#{theobject}\" \"#{thesource}\""
        end
        load thedeps if File.file? thedeps
        Rake::FileTask.define_task thelib => [theobject]
      else
        objects.push f
      end
    end
    Rake::FileTask.define_task thelib do
      puts "[AR] #{thelib}"
      run "#{@@ar} rcs \"#{thelib}\" \"#{objects.join '" "'}\""
    end
    Rake::Task.define_task :default => thelib
    Rake::Task.define_task :clean => :c_clean
  end

  def C.program name, files
    cflags = @@cflags
    theprogram = "#{@@builddir}/#{name}"
    objects = Array.new
    files.each do |f|
      type = /\.[a-zA-Z0-9]+$/.match(f).to_s
      if type == '.c' || type == '.cc' || type == '.cpp' then
        o = f.ext('.o')
        d = f.ext('.deps.rb')
        theobject = "#{@@builddir}/objects/#{o}"
        thedeps = "#{@@builddir}/objects/#{d}"
        thesource = "#{@@sourcedir}/#{f}"
        objects.push theobject
        Rake::FileTask.define_task theobject => [thesource] do
          puts "[CC] #{theobject}"
          run "mkdir -p \"#{@@builddir}/objects\""
          xxx = run "#{@@compiler} #{cflags}#{@@libs} -M \"#{thesource}\""
          xx = []
          File.open(thedeps, 'w') do |f|
            f.puts '# This file was automatically generated. Do not edit!'
            xxx.scan(/\s([^\s\\]+)/) do |x| xx.push x[0] end
            f.puts "Rake::FileTask.define_task #{theobject.dump} => #{xx}"
          end
          run "#{@@compiler} #{cflags}#{@@libs} -c -o \"#{theobject}\" \"#{thesource}\""
        end
        load thedeps if File.file? thedeps
        Rake::FileTask.define_task theprogram => [theobject]
      elsif type == '.a' then
        thefile = "#{@@builddir}/#{f}"
        Rake::FileTask.define_task theprogram => [thefile]
        objects.push thefile
      else
        objects.push f
      end
    end
    Rake::FileTask.define_task theprogram do
      puts "[LD] #{theprogram}"
      run "#{@@compiler} #{@@ldflags} \"-L#{@@builddir}\" -o \"#{theprogram}\" \"#{objects.join '" "'}\""
    end
    Rake::Task.define_task :default => theprogram
    Rake::Task.define_task :clean => :c_clean
  end
end

Rake::Task.define_task :c_clean do
  C.clean
end
