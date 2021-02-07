require_relative "lib/archived_remote_object/version"

Gem::Specification.new do |spec|
  spec.name          = "archived_remote_object"
  spec.version       = ArchivedRemoteObject::VERSION
  spec.authors       = ["Aleksey Strizhak"]
  spec.email         = ["alexei.mifrill.strizhak@gmail.com"]

  spec.summary       = "Get archived remote object with delayed restore"
  spec.description   = "Provide Object to manage Archived remote file."\
                       "Based on AWS-S3 DeepArchive feature: Archived -> Restore in progress -> Temp Available"
  spec.homepage      = "https://github.com/Mifrill/archived_remote_object.git"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/Mifrill/archived_remote_object/blob/master/CHANGELOG.md"

  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-sdk", "~> 3"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "timecop"
end
