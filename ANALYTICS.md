## Analytics Policy

### Goals

- product analytics only
- pseudonymous installation-level analytics only
- explicit opt-in only
- allowlist only
- no PII
- no user-provided content

### Core Rules

1. Analytics starts disabled.
2. User must explicitly opt in before tracking starts.
3. Stable pseudonymous PostHog `distinct_id` allowed.
4. `identify` allowed only with app-generated installation ID.
5. Person profiles allowed only for pseudonymous installation profiles.
6. Every event + property must be listed in this document before implementation.

### Data Rules

Never send:

- media titles
- TMDB IDs
- notes
- tags or tag names
- personal ratings
- watch state values tied to specific media
- search text
- file names or file paths
- URLs with content data
- any free-form text
- any user/account/backend identifier beyond pseudonymous PostHog `distinct_id`

Separate installations on separate devices count as separate pseudonymous IDs.

Allowed property shapes:

- booleans
- small enums
- small enum arrays from fixed allowlists
- counts
- count buckets
- raw durations
- raw error counts
- app version
- app build
- app environment
- platform
- OS family
- OS major version
- device class bucket
- known internal product IDs
- known internal product prices

### Bucket Policy

Import/export count buckets:

- `1_99`
- `100_199`
- `200_299`
- `300_399`
- `400_499`
- `500_999`
- `1000_1999`
- `2000_4999`
- `5000_9999`
- `10000_plus`

Search result count buckets:

- `0`
- `1_99`
- `100_199`
- `200_299`
- `300_399`
- `400_499`
- `500_999`
- `1000_1999`
- `2000_4999`
- `5000_9999`
- `10000_plus`

### SDK Baseline

Required baseline:

```swift
let config = PostHogConfig(apiKey: ..., host: ...)

config.optOut = true
config.captureApplicationLifecycleEvents = true
config.preloadFeatureFlags = true
config.personProfiles = .always

// Recommended unless explicitly needed.
config.sendFeatureFlagEvent = true
```

Notes:

- SDK `optOut` should handle consent gating itself.
- Project configured to discard stored client IP data in PostHog.
- No session replay unless explicitly added here later.
- No autocapture unless explicitly added here later.
- Feature flags allowed.
- Pseudonymous lifecycle events allowed.

### Event Catalog

| Event | Purpose | Approved Properties |
| --- | --- | --- |
| `media_added` | library growth | `media_type` |
| `media_add_failed_pro_limit` | paywall pressure | `media_type` |
| `media_deleted` | library churn | `media_type` |
| `watchlist_toggled` | feature usage | `new_value` |
| `favorite_toggled` | feature usage | `new_value` |
| `bought_pro` | conversion | `product_id`, `price` |
| `restored_pro` | restore usage | none |
| `media_exported` | export usage | `export_count_bucket` |
| `media_imported` | import usage | `import_count_bucket`, `duration_seconds`, `error_count` |
| `library_reset` | extreme churn | none |
| `watch_state_changed` | watched-state feature usage | none |
| `personal_rating_changed` | rating feature usage | none |
| `library_update` | library refresh/update usage | `result` |
| `library_reload` | reload usage | none |
| `tags_imported` | tag import usage | `import_count_bucket`, `duration_seconds`, `error_count` |
| `tags_exported` | tag export usage | `export_count_bucket` |
| `screen_viewed` | screen usage | `screen_name` |
| `custom_list_created` | custom list creation | none |
| `dynamic_list_created` | dynamic list creation | `predicate_type` |
| `custom_list_deleted` | custom list deletion | none |
| `dynamic_list_deleted` | dynamic list deletion | `predicate_type` |
| `library_home_filter_applied` | filter usage | `filter_types` |
| `library_searched` | search feature usage | `result_count_bucket` |
| `setting_changed` | settings/config changes | `setting_key`, `new_value` |
| `media_import_aborted` | import abort usage | `import_count_bucket`, `duration_seconds`, `error_count` |
| `library_home_sorting_changed` | sorting usage | `sorting_order`, `sorting_direction` |
| `library_home_multiselect` | multiselect mode usage | `action` |
| `detail_menu_action_used` | detail menu usage | `action` |
| `library_multiselect_action_used` | library multiselect actions | `action` |
| `media_context_menu_action_used` | long-press context menu usage | `action` |
| `media_swipe_action_used` | swipe action usage | `action` |
| `media_shared` | share feature usage | `share_target_type` |
| `pro_sheet_viewed` | paywall view usage | `source` |
| `pro_purchase_started` | purchase funnel start | `product_id`, `price` |
| `list_configuration_changed` | list customization usage | `field` |
| `import_export_failed` | import/export failure usage | `operation`, `stage` |
| `empty_state_action_used` | empty-state recovery usage | `action`, `screen` |
| `list_media_removed` | removing media from a user list | `list_type` |
| `analytics_enabled` | analytics consent opt-in source | `source` |

### Person Property Catalog

| Property | Purpose | Allowed Values |
| --- | --- | --- |
| `app_environment` | separate debug/release installs | `debug`, `release` |
| `platform` | platform segmentation | `ios` |
| `app_version` | current installed app version | app version string |
| `app_build` | current installed build number | app build string |
| `first_seen_app_version` | first version seen for this installation | app version string |

### Approved Values

`result`:

- `success`
- `failure`

`filter_types` values:

- `unconfigured`
- `adult`
- `media_type`
- `genre`
- `rating`
- `year`
- `status`
- `show_type`
- `number_of_seasons`
- `watch_state`
- `watch_again`
- `tag`
- `watch_provider`
- `compound`

`setting_key` values:

- `show_adults`
- `language`
- `region`
- `default_watch_state`
- `default_subtitle_content`
- `watch_providers`

`source` values for `pro_sheet_viewed`:

- `settings`
- `add_media_limit`
- `upcoming_list_lock`

`source` values for `analytics_enabled`:

- `onboarding`
- `settings`

`field` values for `list_configuration_changed`:

- `name`
- `subtitle_content`
- `icon_name`
- `icon_color`
- `icon_rendering_mode`

`operation` values for `import_export_failed`:

- `media_import`
- `media_export`
- `tags_import`
- `tags_export`

`stage` values for `import_export_failed`:

- `background_task`
- `content_generation`
- `import_processing`

`action` values for `empty_state_action_used`:

- `open_lookup`
- `reset_filter`

`screen` values for `empty_state_action_used`:

- `library_home`
- `media_list`

`list_type` values for `list_media_removed`:

- `custom`

`new_value` notes:

- `watch_providers` must send selected provider count only, never provider names or IDs.

### Change Process

For every analytics change:

1. update this document first
2. list event, purpose, properties, allowed values
3. get approval
4. implement
