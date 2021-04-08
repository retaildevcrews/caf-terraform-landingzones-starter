# Environment Naming

The CAF implmentation of aks-secure-baseline uses a terraform provider, [azurecaf_name](https://registry.terraform.io/providers/aztfmod/azurecaf/latest/docs/resources/azurecaf_name), to name all the azure resources. This provider has different settings that can be used to control the generated names.

To get deterministic names, use these settings. The `global_settings` is set in [global_settings.tfvars](./configuration/global_settings.tfvars)

- passthrough = false
  - Controls if resource names are passed in as-is or modified based on other settings.
  - Disable this to allow the naming provider to use other settings.
- random_length = 0
  - Appends random characters on every terraform run.
  - Disable this to get consistent resource names.
- prefix = "\<a unique environment prefix\>"
  - Adds a prefix to resource names

These combination of settings allows for creating isolated environments with deterministic names.

## Naming Convention

The naming convention for the prefix is (optional project-short-form)-(team-name)-(environment)

Examaple:

- `ngsa-mon-dev` or `mon-dev` for monitoring dev environment
- `ngsa-pnp-dev` or `pnp-dev` for pnp deploy dev environment

```terraform

global_settings = {
  passthrough    = false
  random_length  = 0
  prefix         = "ngsa-pnp-dev"
}

```

For personal environments for testing, use a prefix that is unique to you. Your alias for example.

Example:

- `myalias-test`

```terraform

global_settings = {
  passthrough    = false
  random_length  = 0
  prefix         = "myalias-test"
}

```
