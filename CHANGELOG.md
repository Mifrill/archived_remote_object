[0.1.5]: https://github.com/mifrill/archived_remote_object/compare/v0.1.4...v0.1.5

## [0.1.5] ##

Implemented feature to check remote-object existence by provided key

[0.1.4]: https://github.com/mifrill/archived_remote_object/compare/v0.1.3...v0.1.4

## [0.1.4] ##

Implemented feature to delete remote-object by provided key 

[0.1.3]: https://github.com/mifrill/archived_remote_object/compare/v0.1.2...v0.1.3

## [0.1.3] ##

Implemented feature to assign tag with key-value for the remote-object

[0.1.2]: https://github.com/mifrill/archived_remote_object/compare/v0.1.1...v0.1.2

## [0.1.2] ##

Implemented feature to stop archiving remote-object on duration

[0.1.1]: https://github.com/mifrill/archived_remote_object/compare/v0.1.0...v0.1.1

## [0.1.1] ##

add files into gem release / add fill CHANGELOG / add description into README

[0.1.0]: https://github.com/Mifrill/archived_remote_object/releases/tag/v0.1.0

## [0.1.0] ##

The skeleton implementation:

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
