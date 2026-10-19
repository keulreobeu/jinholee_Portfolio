# 부동이 개인 고도화 · 검색 근거와 답변 평가

2023년 팀 부동이를 이후 개인 작업으로 확장한 프로젝트입니다. 데이터 정제와 QA·평가·학습 진입 기준을 나누고, 답변이 어떤 근거에 기반해야 하는지 정리했습니다.

## 문제와 구성

이종 데이터를 준비한 뒤에도 모델이 근거 없는 추천을 하거나 검증 범위를 벗어난 답을 낼 수 있었습니다. retrieval-first 방식, 추천 제한, holdout/edge 평가와 학습 진입 기준을 구성했습니다. 실제 답변 품질을 어떻게 판정할지에서 한계를 경험했고 이후 도메인 경험자와 팀을 꾸려 집담으로 이어갔습니다.

## 데이터 규모와 버전

현재 보고서 기준 RAG 데이터 3,239행·87열, QA61,560건 생성 후 56,392건, Eval1,000건·Edge2,000건, SFT 원 분할 train889/valid99가 기록돼 있습니다. QA 전체가 SFT 학습 데이터는 아닙니다. r5 contextual train756/valid84는 별도 실행 분할입니다.

초기 보고서의 80,975→74,175와 최신 61,560→56,392를 섞지 않습니다. 원 QA CSV가 공개되지 않아 이번에 행 수를 직접 집계하지 않았습니다.

## 결과의 해석

stage06 readiness GO는 학습 실험 진입 조건이며 최종 서비스 품질 판정이 아닙니다. post-train verdict의 experiment_only, deterministic/mock 경로와 실제 모델 추론을 구분합니다. unsafe recommendation5→0 같은 값은 해당 실행·holdout·경로를 함께 확인해야 하므로 대표 실모델 성과로 넣지 않았습니다.

## 구현·재현

[원본 저장소](https://github.com/keulreobeu/Real_estate_Chatbot_by_gemma4) · [QA 보고서](https://github.com/keulreobeu/Real_estate_Chatbot_by_gemma4/blob/main/00_Report/03_qa_generation_report.md) · [프로젝트 상세](https://app.notion.com/p/349ba28e5f5b80a692ffd461b3f1e034)

공개 보고서와 실행별 산출물부터 읽고 동일 모델 ID·원 데이터·독립 holdout·환경을 준비한 뒤 평가해야 합니다. 이번 작업은 학습/추론을 실행하지 않았습니다. GPU·모델 로드 성공만으로 학습 및 생성 품질 검증 완료를 주장하지 않습니다.

[집담 후속 작업](jipdam.md) · [전체 포트폴리오](../README.md)
