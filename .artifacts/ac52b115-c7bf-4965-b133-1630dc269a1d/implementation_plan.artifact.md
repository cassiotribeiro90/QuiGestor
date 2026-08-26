# Fix TypeError in Filter Options Parsing

The application crashes with `TypeError: 20: type 'int' is not a subtype of type 'List<dynamic>'` because the API response for `filter_options` contains integer counts for some keys (like `destaque` and `verificado`), but the code tries to cast them all to `List`.

## User Review Required

> [!NOTE]
> I am changing `FilterGroup.fromJson` to return `null` when the data is not a list. This will cause these specific filters (destaque/verificado) to disappear from the UI until they are formatted as a list of options by the backend or the frontend handles them specifically as counts.

## Proposed Changes

### [Models]

#### [MODIFY] [filter_option.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/models/filter_option.dart)
- Convert `FilterGroup.fromJson` from a `factory` to a `static` method returning `FilterGroup?`.
- Add a check: `if (json is! List) return null;`.
- Ensure type-safe mapping of options.

### [Views]

#### [MODIFY] [lojas_list_screen.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/modules/lojas/views/lojas_list_screen.dart)
- Update `GenericFilterWidget` to filter out null groups.

#### [MODIFY] [categorias_list_screen.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/modules/categorias/views/categorias_list_screen.dart)
- Update `GenericFilterWidget` to filter out null groups.

#### [MODIFY] [gestores_list_screen.dart](file:///C:/Users/cassi/projetos/quigestor/lib/app/modules/gestores/views/gestores_list_screen.dart)
- Update `GenericFilterWidget` to filter out null groups.

## Verification Plan

### Automated Tests
- I will check if I can run a small scratch script to verify the logic.

### Manual Verification
- Navigate to **Lojas**, **Categorias**, and **Gestores** screens.
- Verify that the app no longer crashes.
- Verify that valid filter groups (like "Status" and "Categoria") are still visible and functional.
