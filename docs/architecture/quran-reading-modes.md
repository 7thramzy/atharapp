# Athaar Quran reading modes

## Product rule

**Hafs 'an Asim is the default and reference reading mode inside Athaar.** The 604-page QCF Mushaf renderer is the primary Quran-reading experience. Its UI uses the label "المصحف المعتمد داخل أثَر — حفص عن عاصم".

The imported Tanzil Uthmani v1.1 dataset powers a second, lightweight local text view. It is an auxiliary text-reading mode for search, quick access, and devices where a text list is more convenient. It must not be labelled as a separate riwayah, and the app must not claim that the Tanzil text data file is the same resource as the QCF 604-page Mushaf assets.

## Shared location

Both reading screens exchange one stable coordinate: (surah number, ayah number).

- Downloaded text -> Hafs: pass `surah` and `ayah` in the Mushaf route query.
- Hafs -> downloaded text: pass the selected ayah; when no ayah is selected, use the first ayah on the currently visible QCF page.
- Both modes save the same reading position in Drift while setting `readingMode` to `downloaded_text` or `hafs_mushaf`.
- Returning to a screen restores the last saved surah and ayah. The Hafs adapter maps the coordinate to the standard 604-page layout.
- Selecting an ayah or word in the Hafs Mushaf updates the shared position immediately. Selecting an ayah card in the text view does the same.

## Integrity boundaries

The text view displays Tanzil Uthmani v1.1 as acquired and validated by the dataset import pipeline. It does not edit the canonical text. The Hafs reader remains the reference page-layout renderer; no text-source substitution or silent merging of fonts/page coordinates is performed.

## UI wording

- Reference mode: "المصحف المعتمد — حفص عن عاصم".
- Auxiliary mode: "النص المحلي — Tanzil Uthmani 1.1 · وضع مساعد".
- Switching modes must preserve the current ayah coordinate.
