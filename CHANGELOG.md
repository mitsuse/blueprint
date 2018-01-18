## Unreleased


## 0.4.0

- The ID of the current user should be obtained from `Session`.


## 0.3.0

- `Serivce` is residents in a app to do some task for the single purpose.
- `CommandHandler` is used for `Service` to process commands exclusively. Currently, Blueprint provides only one implementation of `CommandHandler`:
    - `LeakyCommandHandler`: omits received commands while it is busy.


## 0.2.0

- Add `Session` protocol type. This type manages the user who signs in currently.
