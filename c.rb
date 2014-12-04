require 'rake'

class C
  @@cflags = '-Wall'
  @@compiler = ENV['CC'] || 'cc'
  @@builddir = 'build'
  @@sourcedir = 'src'
  @@libs = ''

  def C.run cmd
    raise "Error: '#{cmd}'" unless system cmd
  end

  def C.clean
    run "rm -rf \"#{@@builddir}\""
  end

  def C.cflags
    @@cflags
  end

  def C.cflags= flags
    @@cflags = flags
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
        theobject = "#{@@builddir}/objects/#{name}/#{o}"
        thesource = "#{@@sourcedir}/#{name}/#{f}"
        objects.push theobject
        Rake::Task.define_task theobject => [thesource] do
          puts "[CC] #{theobject}"
          run "mkdir -p \"#{@@builddir}/objects/#{name}\""
          run "#{@@compiler} #{cflags}#{@@libs} -c -o \"#{theobject}\" \"#{thesource}\""
        end
        Rake::Task.define_task thelib => [theobject]
      else
        objects.push f
      end
    end
    Rake::Task.define_task thelib do
      puts "[AR] #{thelib}"
      run "ar rcs \"#{thelib}\" \"#{objects.join '" "'}\""
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
        theobject = "#{@@builddir}/objects/#{o}"
        thesource = "#{@@sourcedir}/#{f}"
        objects.push theobject
        Rake::Task.define_task theobject => [thesource] do
          puts "[CC] #{theobject}"
          run "mkdir -p \"#{@@builddir}/objects\""
          run "#{@@compiler} #{cflags}#{@@libs} -c -o \"#{theobject}\" \"#{thesource}\""
        end
        Rake::Task.define_task theprogram => [theobject]
      elsif type == '.a' then
        thefile = "#{@@builddir}/#{f}"
        Rake::Task.define_task theprogram => [thefile]
        objects.push thefile
      else
        objects.push f
      end
    end
    Rake::Task.define_task theprogram do
      puts "[LD] #{theprogram}"
      run "#{@@compiler} \"-L#{@@builddir}\" -o \"#{theprogram}\" \"#{objects.join '" "'}\""
    end
    Rake::Task.define_task :default => theprogram
    Rake::Task.define_task :clean => :c_clean
  end
end

Rake::Task.define_task :c_clean do
  C.clean
end
