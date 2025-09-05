# Book Insights Feature - Requirements Document

## Introduction

The Book Insights feature enhances the InsiBook Mobile application by providing users with bite-sized knowledge extracted from books as an alternative to full summaries. This feature will be integrated into the existing book details screen, allowing users to choose between reading comprehensive summaries or consuming quick, actionable insights. The insights will be displayed as digestible pieces of knowledge that capture the most valuable takeaways from each book.

## Requirements

### Requirement 1: Insights Display Option and Navigation

**User Story:** As a reader, I want to choose between viewing book summaries or insights on the book details screen and seamlessly navigate between both screens when reading, so that I can consume content in the format that best fits my available time and learning preferences.

#### Acceptance Criteria

1. WHEN a user navigates to a book details screen THEN the system SHALL display two content viewing options: "Read Summary" button and "View Insights" button
2. WHEN a user selects the "Read Summary" button THEN the system SHALL navigate to the existing book summary screen
3. WHEN a user selects the "View Insights" button THEN the system SHALL navigate to the new book insights screen
4. WHEN a user is in the summary screen THEN the system SHALL provide a navigation option to switch to insights screen
5. WHEN a user is in the insights screen THEN the system SHALL provide a navigation option to switch to summary screen
6. WHEN a user switches between summary and insights screens THEN the navigation SHALL be seamless without returning to the book details screen
7. WHEN the book details screen loads THEN both options SHALL be equally visible to maintain feature discoverability

### Requirement 2: Insights Content Structure and Categorization

**User Story:** As a reader, I want insights to be presented as categorized, bite-sized knowledge with specific types (key idea, opinion, recommendation, habit, quote), so that I can quickly identify and consume different types of valuable information from the book.

#### Content Structure Acceptance Criteria

1. WHEN insights are displayed THEN each insight SHALL contain concise text content (approximately 50 words but flexible based on content needs)
2. WHEN insights are rendered THEN each insight SHALL be categorized as one of five types: "key idea", "opinion", "recommendation", "habit", or "quote"
3. WHEN insights are shown THEN they SHALL be displayed in a table format for structured presentation
4. WHEN multiple insights exist for a book THEN the system SHALL display them in a scrollable table with clear rows and columns
5. WHEN no insights are available for a book THEN the system SHALL display an appropriate message indicating insights are not yet available
6. WHEN insights are categorized THEN each type SHALL have distinct visual styling to differentiate between categories

### Requirement 3: Insights Data Integration

**User Story:** As a system administrator, I want insights data to be seamlessly integrated with the existing API architecture, so that the feature can leverage the current backend infrastructure and data models.

#### Data Integration Acceptance Criteria

1. WHEN the insights screen is accessed for the first time THEN the system SHALL make a separate API call to fetch insights data for that specific book
2. WHEN insights data is retrieved THEN the system SHALL use the existing BookApiService for API communication
3. WHEN insights are fetched THEN the system SHALL handle the data using appropriate model classes following the existing architecture patterns
4. WHEN API requests fail THEN the system SHALL handle insights-related errors gracefully without breaking the summary functionality
5. WHEN insights data is unavailable THEN the system SHALL continue to function normally with only summary content accessible

### Requirement 4: User Interface Integration

**User Story:** As a user, I want the insights feature to feel naturally integrated into the existing book details interface, so that I have a seamless and intuitive experience when exploring book content.

#### UI Integration Acceptance Criteria

1. WHEN the insights feature is added THEN the system SHALL maintain the existing Material 3 design system consistency
2. WHEN content switching controls are displayed THEN they SHALL follow established UI patterns and component styling from the app
3. WHEN insights are shown THEN they SHALL use readable typography and spacing consistent with the summary display
4. WHEN users interact with insights THEN the system SHALL provide appropriate visual feedback and loading states
5. WHEN the insights view is active THEN the system SHALL clearly indicate which content mode is currently selected

### Requirement 5: Performance and Data Loading Strategy

**User Story:** As a user, I want insights to load efficiently only when needed and remain cached during navigation, so that I can switch between summary and insights screens without unnecessary loading delays.

#### Performance Acceptance Criteria

1. WHEN a user first navigates to the insights screen THEN the system SHALL fetch insights data from the API only at that time
2. WHEN insights data is successfully loaded THEN the system SHALL cache it in memory for the current session
3. WHEN a user navigates back and forth between summary and insights screens THEN the system SHALL NOT make additional API calls for insights data
4. WHEN insights data is being fetched for the first time THEN the system SHALL implement appropriate loading states during data retrieval
5. WHEN insights fail to load THEN the system SHALL display appropriate error messages and fallback options
6. WHEN insights data is cached and displayed THEN the system SHALL implement efficient rendering to maintain smooth scrolling performance
7. WHEN network connectivity is poor THEN the system SHALL handle timeouts gracefully and provide retry mechanisms

### Requirement 6: Visual Differentiation and Table Presentation

**User Story:** As a reader, I want each insight type to have distinct visual styling in a well-organized table format, so that I can quickly scan and identify different categories of knowledge (key ideas, opinions, recommendations, habits, quotes).

#### Content Presentation Acceptance Criteria

1. WHEN insights are displayed in table format THEN each insight type SHALL have a unique visual indicator (color, icon, or styling)
2. WHEN "key idea" insights are shown THEN they SHALL use distinct visual styling to indicate core concepts
3. WHEN "opinion" insights are displayed THEN they SHALL have visual styling that differentiates them from factual content
4. WHEN "recommendation" insights are presented THEN they SHALL use actionable-focused visual styling
5. WHEN "habit" insights are shown THEN they SHALL have behavioral-focused visual indicators
6. WHEN "quote" insights are displayed THEN they SHALL use quotation-style visual formatting
7. WHEN the insights table is long THEN the system SHALL implement smooth scrolling with appropriate performance optimization
8. WHEN insights content is empty or malformed THEN the system SHALL handle these edge cases gracefully with appropriate messaging

### Requirement 7: Backward Compatibility

**User Story:** As an existing user, I want the new insights feature to not disrupt my current workflow with book summaries, so that I can continue using the app as before while having access to new functionality.

#### Compatibility Acceptance Criteria

1. WHEN the insights feature is deployed THEN existing summary functionality SHALL remain unchanged and fully operational
2. WHEN users access book details THEN the default view SHALL remain as the summary view to preserve existing user experience
3. WHEN API responses include insights data THEN books without insights SHALL continue to display summaries normally
4. WHEN insights feature encounters errors THEN summary functionality SHALL remain unaffected and accessible
5. WHEN users who don't use insights access book details THEN their experience SHALL be identical to the previous version

### Requirement 8: Data Model Extensions

**User Story:** As a developer, I want the insights feature to extend existing data models with proper structure for insight content and types, so that the implementation follows established architectural patterns and maintains code quality.

#### Data Model Acceptance Criteria

1. WHEN insights data is handled THEN the system SHALL create an Insight model class with 'content' (String) and 'type' (enum: key_idea, opinion, recommendation, habit, quote) fields
2. WHEN insights are integrated THEN the BookWithSummary model SHALL be extended or a new model created to include a List of Insight objects field
3. WHEN JSON deserialization occurs THEN insights data SHALL use factory constructors consistent with existing model patterns
4. WHEN insight types are handled THEN the system SHALL use an enum or constants for the five insight types to ensure type safety
5. WHEN insights models are created THEN they SHALL include proper null safety handling following Dart best practices
6. WHEN insights data structure changes THEN the models SHALL be flexible enough to handle variations without breaking the app
