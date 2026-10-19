# 코드 확인과 재현 안내

2026.10.19 기준 집담 고정 commit `dfd65523de303d060c2bb1c1b5102730feeeaff9`을 대상으로 합니다. 원 데이터·모델 없이 가능한 합성 검사와 실제 자료가 필요한 실행을 나눕니다.

## 집담: 모델·API 키 없는 시작

Python3.11 이상과 Git이 필요합니다. 새 작업 폴더에서 실행합니다. 의존성 설치에는 패키지 네트워크가 필요합니다.

```powershell
git clone https://github.com/keulreobeu/jipdam.git
cd jipdam
git checkout dfd65523de303d060c2bb1c1b5102730feeeaff9
python -m venv .venv
.venv/Scripts/python.exe -m pip install -e outputs/budongi_mvp_temp
.venv/Scripts/python.exe -X utf8 scripts/bootstrap.py --app-only
```

`--app-only`는 gstack·브라우저 설치를 생략하고 제품/팀 검사와 합성 smoke를 실행합니다. 이번 포트폴리오에서는 이 설치 전체 명령이 아니라 **번들 의존성 환경에서 아래 제품 검사 281개**를 실행했습니다. 설치의 새 PC 재현과 구분합니다.

```powershell
cd outputs/budongi_mvp_temp
$env:PYTHONPATH = (Resolve-Path src).Path
$python = (Resolve-Path ../../.venv/Scripts/python.exe).Path
& $python -X utf8 -m unittest discover -s tests -v
& $python -X utf8 -m budongi.cli rental-demo --directory data/rental/portfolio-demo
& $python -X utf8 -m budongi.cli recommend --rental-db data/rental/portfolio-demo/serving.sqlite3 --snapshot-id synthetic_rental_demo_v1 --request data/rental/portfolio-demo/request.json --allow-synthetic
```

`rental-demo`의 실제 출력에 표시되는 DB·snapshot·request 경로를 사용합니다. 기존 출력이 있으면 새 디렉터리를 지정합니다. 합성 단지 3개로 만든 기본 요청은 2곳을 반환하고 역 선호는 unknown입니다. 실제 추천 품질의 증거가 아닙니다.

## 실제 데이터가 필요한 경로

다음은 **입력 준비 후 실행하는 안내**입니다. 저장소 clone에 원본 DB·검수 패키지·모델이 들어 있다고 가정하지 않습니다. `BATCH` 등은 준비한 경로로 바꿉니다. 실제 API 수집 명령은 자동 실행하지 않습니다.

```powershell
& $python -m budongi.cli collection status --directory data/collection/BATCH
& $python -m budongi.cli collection build-db --directory data/collection/BATCH --output data/collection/BATCH/db-new
& $python -m budongi.cli collection integrate --directory data/collection/BATCH --db-directory data/collection/BATCH/db-new --output data/collection/BATCH/canonical-new
```

원본 해시·manifest·출처/지역/월 범위가 일치해야 합니다. 실제 추천 serving은 원본 canonical에 더해 승인된 검수 관계/좌표/시설/커버리지 패키지가 필요합니다. 정확한 옵션과 형식은 고정 commit의 [검수 패키지 안내](https://github.com/keulreobeu/jipdam/blob/dfd65523de303d060c2bb1c1b5102730feeeaff9/outputs/budongi_mvp_temp/docs/rental-review-package.md)를 따릅니다. 준비되지 않으면 `data_not_ready`가 정상입니다.

## 기존 프로젝트

| 프로젝트 | 공개된 확인 대상 | 전체 실행에 필요한 추가 자료 |
|---|---|---|
| 부동이 2023 | 수집·전처리·회귀 노트북, 저장 출력 | 원 CSV·당시 패키지·Azure 서비스 코드/설정 |
| 비전 AI | 전처리·모델·이벤트/문서화 코드와 문서 | 영상·라벨·가중치·환경·분할 기준 |
| 박테리아 | 전처리/모델 비교 노트북 | 입력데이터·분할·가중치·고정 패키지 |
| 개인 고도화 | QA·평가·학습진입 보고서와 실행 코드 | 원 QA/평가 데이터·모델 ID·holdout·환경 |

누락된 입력을 임의 생성해 과거 성능을 재현했다고 표시하지 않습니다. 실행 근거와 현재 한계는 프로젝트별 문서에 함께 적었습니다.
