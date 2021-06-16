[![CircleCI](https://circleci.com/gh/Mifrill/archived_remote_object.svg?style=svg)](https://app.circleci.com/pipelines/github/Mifrill/archived_remote_object)

# ArchivedRemoteObject

Based on AWS-S3 DeepArchive feature: Archived -> Restore in progress -> Temp Available

Provided OOP interface to manage the archived remote file.

https://docs.aws.amazon.com/AmazonS3/latest/dev/storage-class-intro.html

The skeleton structure:

```
    Archive::RestoredObject
      archived_object: Archive::ArchivedObject
        remote_object: AwsS3::ArchivedObject
          remote_object: AwsS3::RemoteObject
            remote_client: AwsS3::Client
```

- AwsS3::Client - low-level simple awsS3 client to send external requests: `head_object/restore`

- AwsS3::RemoteObject - wrapper with the common logic to realize memoization fetched object data from s3_client

- AwsS3::ArchivedObject - wrapper with specific archive/restore AWS logic, methods: `archived?/restore_in_progress?/restored?/restore`

- Archive::ArchivedObject - high-level object with common logic related to "archive", like validation etc.

- Archive::RestoredObject - high-level object to realize the logic of general-idea:
  Archived (fire restore automatically) -> Restore in progress -> Temp Available

- ArchivedRemoteObject module with `get_object` method to realize full skeleton logic

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'archived_remote_object'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install archived_remote_object

## Usage

```
ArchivedRemoteObject.configure do |config|
  config.aws_region = ENV["AWS_REGION"]
  config.aws_bucket = ENV["AWS_S3_ARCHIVED_REMOTE_BUCKET_NAME"]
  config.aws_access_key_id = ENV["AWS_ACCESS_KEY_ID"]
  config.aws_secret_access_key = ENV.fetch["AWS_SECRET_ACCESS_KEY"]
  config.archive_restore_duration_days = ENV["AWS_ARCHIVE_RESTORE_DURATION_DAYS"]
end

archived_remote_object = ArchivedRemoteObject.get_object("aws-file-key")
archived_remote_object.status == :available if File is not archived or File restored and temp available with provided duration
archived_remote_object.status == :in_progress if File restoration in progress
archived_remote_object.status == :restoration_initiated if File was archived but now restoration fired
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `rake install`. To release a new version, update the version number in `version.rb`, and then run `rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Mifrill/archived_remote_object. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/Mifrill/archived_remote_object/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ArchivedRemoteObject project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Mifrill/archived_remote_object/blob/master/CODE_OF_CONDUCT.md).
