## Unreleased

- Session handles errors on authentication/authorization.

## 0.11.0

- Update dependencies.


## 0.8.0

- Support asynchronous updates.


## 0.7.0

- Update the version of RxSwift.


## 0.5.0

- Add an in-memory implementation of `Session`.
- Add an extension to observe the transitions of the entity specified with the current user ID.


## 0.4.0

- The ID of the current user should be obtained from `Session`.


## 0.3.0

- `Serivce` is residents in a app to do some task for the single purpose.
- `CommandHandler` is used for `Service` to process commands exclusively. Currently, Blueprint provides only one implementation of `CommandHandler`:
    - `LeakyCommandHandler`: omits received commands while it is busy.


## 0.2.0

- Add `Session` protocol type. This type manages the user who signs in currently.
