# Product Steering Guide

## Purpose
InsiBook Mobile is a Flutter application for searching and reading AI-generated book summaries. The app allows users to discover books through both internal databases and Google Books API, then access high-quality AI-generated summaries to quickly understand book content.

## Core Features
- **Book Search**: Search through internal book database and Google Books API simultaneously
- **Book Discovery**: Browse latest books and categories 
- **Summary Reading**: Access AI-generated book summaries with structured chapter content
- **User Authentication**: Login/register system with JWT token management
- **Multi-language Support**: English and Vietnamese localization
- **Cross-platform**: Supports iOS, Android, web, and desktop platforms

## Key Business Logic
- Prioritize internal books over Google Books results when displaying search results
- Support async summary generation - books can be requested for summarization if not available
- Implement proper authentication flow with token-based security
- Handle offline/network connectivity gracefully with appropriate error states
- Maintain dark theme consistency across all screens for optimal reading experience

## User Value Proposition
- **Time-saving**: Get book insights without reading entire books
- **Discovery**: Find relevant books through comprehensive search across multiple sources
- **Accessibility**: Read summaries in preferred language (English/Vietnamese)
- **Convenience**: Access book knowledge on mobile devices with offline-friendly design

## Content Guidelines
- Always display book covers when available (Google Books images preferred)
- Show clear distinction between internal books (with summaries) and Google Books (summary can be requested)
- Provide rich metadata including authors, categories, publication info
- Format summary content with proper markdown rendering for readability