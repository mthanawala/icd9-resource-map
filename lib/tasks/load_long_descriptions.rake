namespace :code do
  desc 'Load descriptions for codes from specified file'
  task :load_descriptions, [:file] => :environment do |t, args|
    file = args.file
    File.readlines(file).each do |line|
      line.chomp!
      code, description = line.encode('UTF-8', :invalid => :replace).split(/\s+/, 2)
      Code.find_by_code(code).update_attribute(:description, description)
    end
  end

end
