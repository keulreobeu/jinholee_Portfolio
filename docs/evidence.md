# 수치·상태의 근거

집담의 링크는 검토 시점 main commit으로 고정합니다. 문서는 구현 기록이고 원시 데이터의 독립 재집계와 같지 않습니다.

| 주장 | 근거 |
|---|---|
| canonical374,892·원본 384,211·재적재 0·17개 테이블 대사·SQL 병목 | [canonical 감사](https://github.com/keulreobeu/jipdam/blob/dfd65523de303d060c2bb1c1b5102730feeeaff9/outputs/budongi_mvp_temp/docs/canonical-validation-20261013.md) |
| 수집 2,400query·전월세 685,575·매매각 192,142, 별도 배치 | [역사 수집 감사](https://github.com/keulreobeu/jipdam/blob/dfd65523de303d060c2bb1c1b5102730feeeaff9/outputs/budongi_mvp_temp/docs/molit-statistics-history-validation-20261015.md) |
| XLSX30·날짜셀 530,556·숫자/결측 분리 | [통계 검증](https://github.com/keulreobeu/jipdam/blob/dfd65523de303d060c2bb1c1b5102730feeeaff9/outputs/budongi_mvp_temp/docs/statistics-validation-20261013.md) |
| serving238,620·확정 0·합성 p95 | [추천 MVP 검증 최종 절](https://github.com/keulreobeu/jipdam/blob/dfd65523de303d060c2bb1c1b5102730feeeaff9/outputs/budongi_mvp_temp/docs/rental-mvp-validation-20261013.md) |
| 실제 추천/모델 준비 미완료·다운로드 해시 검증 | [후속 검증](https://github.com/keulreobeu/jipdam/blob/dfd65523de303d060c2bb1c1b5102730feeeaff9/outputs/budongi_mvp_temp/docs/continuation-validation-20261014.md) |
| CLI 하네스·이전 최종 281개·native GMS 미완료 | [하네스 운영 검증](https://github.com/keulreobeu/jipdam/blob/dfd65523de303d060c2bb1c1b5102730feeeaff9/outputs/budongi_mvp_temp/docs/harness/OPERATIONS_UPDATE_20261015.md) |
| 현재 main CI success | [38684231404](https://github.com/keulreobeu/jipdam/actions/runs/38684231404) |
| 별도 최신 브랜치 CI failure | [38705267401](https://github.com/keulreobeu/jipdam/actions/runs/38705267401) |
| 부동이 R² 0.9728·평당공급액·80:20/early stopping | [회귀 저장 출력](https://github.com/keulreobeu/jinholee_Portfolio/blob/master/Azure_GPT/04_house_mashine_learning.ipynb), 사용자 확인·기존 검토 기록 |
| 부동이 기간·팀성과·개인역할, 교육·자격 | 사용자 제공 대화 및 확정 작성 기준(2026.10.07–08) |
| 비전 280건·개인역할 | [기존 프로젝트 문서](https://app.notion.com/p/2d5ba28e5f5b801fac2cf5a2b2052d60), 사용자 확정 기간 |
| 박테리아 95.72%와 스태킹 구분 | [기존 프로젝트 문서](https://app.notion.com/p/2a4ba28e5f5b803a98a6f9019679fbad), 사용자 확정값 |
| 최신 QA61,560→56,392 | [QA 보고서](https://github.com/keulreobeu/Real_estate_Chatbot_by_gemma4/blob/main/00_Report/03_qa_generation_report.md), 기존 버전 대조 |

이번 직접 실행: 2026.10.19, 고정 main의 제품 unittest281개,49.552초,OK. 테스트는 합성/모델 없는 계약검증이며 실제 수집이나 추천 품질 점수가 아닙니다. 첫 sandbox 권한 오류와 허용 로컬 재검증을 구분해 작업 기록에 보존했습니다.

공개 문서에는 비밀 키·자격증명 ID·계정 잔액·원본 DB/ZIP·개인 경로를 포함하지 않습니다. 프로젝트의 문제 정의와 확인된 개인 기여, 저장소의 구현 결과를 구분합니다.
