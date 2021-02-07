[0.1.1]: https://github.com/mifrill/archived_remote_object/compare/v0.1.0...v0.1.1

## [0.1.1] ##

add files into gem release / add fill CHANGELOG

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

- AwsS3::Client - low-level awsS3 client to send external requests: `head_object/restore`

- AwsS3::RemoteObject - wrapper with common logic with memoization fetched object data from s3_client

- AwsS3::ArchivedObject - wrapper with specific archive/restore AWS logic, methods: `archived?/restore_in_progress?/restored?/restore`

- Archive::ArchivedObject - high-level object with common related archived logic, like validation etc.

- Archive::RestoredObject - high-level object with general-idea logic: 
    Archived (fire restore if archived) -> Restore in progress -> Temp Available

- ArchivedRemoteObject module with `get_object` method to realize skeleton logic
