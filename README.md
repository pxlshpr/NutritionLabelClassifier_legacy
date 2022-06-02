# Nutrition Facts Classifier
A Swift framework that classifies Nutrition Label features from [recognized text observations](https://developer.apple.com/documentation/vision/vnrecognizedtextobservation) extracted using the [Vision framework](https://developer.apple.com/documentation/vision).

## Releases

### 0.0.117
#### Failing Test
- Test Case: C132B648-8974-457A-8EE6-824688D901EA
- Attribute: `.protein.value2`
- Expected: `4.3g`
- Observation: `43g`

#### Possible Heuristic
- Check if we have any other candidates for the recognized text for `value2` that equals the correct value.
- If we do, add a heuristic that makes sure `value2 < value1`, and if not, it goes through other candidates till a valid `Value` is found

#### Changes
- 