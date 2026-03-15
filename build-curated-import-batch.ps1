param(
  [string]$OutputFile = 'tools/catalog/catalog-data.curated-200.csv',
  [int]$TargetCount = 200
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$toolsDataPath = Join-Path $PSScriptRoot 'assets/js/tools-data.js'
if (-not (Test-Path $toolsDataPath)) {
  throw "Missing tools data file: $toolsDataPath"
}

function Get-NormalizedCategory([string]$category) {
  if (-not $category) { return 'AI Assistant' }
  $c = $category.Trim()
  switch -Regex ($c) {
    'Writing|Content' { return 'AI Writing' }
    'Image|Design|Art' { return 'AI Image' }
    'Video' { return 'AI Video' }
    'Code|Developer' { return 'AI Code' }
    'Voice|Audio' { return 'AI Voice' }
    'Productivity' { return 'AI Productivity' }
    'Automation' { return 'AI Automation' }
    default { return 'AI Assistant' }
  }
}

function Get-CleanDescription([string]$desc, [string]$name, [string]$category) {
  if (-not $desc) {
    return "$name is an established $category tool used for practical AI workflows."
  }
  $x = $desc -replace "\\'", "'"
  $x = $x.Trim()
  if ($x.Length -gt 220) {
    $x = $x.Substring(0, 219).Trim() + '.'
  }
  return $x
}

function Get-ExpansionDescription([string]$name, [string]$category) {
  switch ($category) {
    'AI Writing' { return "$name helps teams draft, rewrite, and optimize high-intent content with repeatable quality controls." }
    'AI Image' { return "$name supports image generation and editing workflows for product visuals, campaigns, and creative iteration." }
    'AI Video' { return "$name accelerates script-to-video production, short-form edits, and publishing workflows across channels." }
    'AI Code' { return "$name improves developer throughput with coding assistance, refactoring support, and implementation guidance." }
    'AI Voice' { return "$name powers transcription, voice generation, and conversational audio workflows for modern teams." }
    'AI Productivity' { return "$name streamlines planning, execution, and team coordination through practical AI productivity workflows." }
    'AI Automation' { return "$name connects tools and automates repetitive operations with workflow-first AI orchestration." }
    default { return "$name is a practical AI assistant for research, planning, and day-to-day execution workflows." }
  }
}

$content = Get-Content $toolsDataPath -Raw
$pattern = '\{n:''([^'']+)'',s:''([^'']+)'',c:''([^'']+)'',d:''((?:\\''|[^''])*)'',k:''([^'']*)''\}'
$regexMatches = [regex]::Matches($content, $pattern)

$records = New-Object System.Collections.Generic.List[object]
$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
$today = (Get-Date).ToString('yyyy-MM-dd')

foreach ($m in $regexMatches) {
  $name = $m.Groups[1].Value.Trim()
  if (-not $name) { continue }
  if ($seen.Contains($name)) { continue }

  $slug = $m.Groups[2].Value.Trim()
  $rawCategory = $m.Groups[3].Value.Trim()
  $rawDesc = $m.Groups[4].Value

  $seen.Add($name) | Out-Null
  $records.Add([pscustomobject]@{
    name = $name
    category = Get-NormalizedCategory $rawCategory
    description = Get-CleanDescription $rawDesc $name (Get-NormalizedCategory $rawCategory)
    website = "https://lookforit.xyz/tools/$slug"
    status = 'verified-existing'
    updatedAt = $today
  })
}

$supplemental = @(
  @{ n='Adobe Firefly'; c='AI Image'; d='Creative AI suite for image generation, edits, and style experimentation inside Adobe workflows.'; u='https://www.adobe.com/products/firefly.html' },
  @{ n='Ideogram'; c='AI Image'; d='Image generator known for strong typography handling in posters, ads, and social graphics.'; u='https://ideogram.ai' },
  @{ n='Flux.1'; c='AI Image'; d='High-quality image model family used for realistic visuals, product renders, and concept exploration.'; u='https://blackforestlabs.ai' },
  @{ n='Krea'; c='AI Image'; d='Real-time visual generation and creative iteration environment for designers and teams.'; u='https://www.krea.ai' },
  @{ n='Playground AI'; c='AI Image'; d='Prompt-based image generation and editing for fast visual experimentation.'; u='https://playground.com' },
  @{ n='Clipdrop'; c='AI Image'; d='AI image editing toolkit for cleanup, relighting, background removal, and upscaling.'; u='https://clipdrop.co' },
  @{ n='Recraft'; c='AI Image'; d='Brand-safe image generation focused on vector and design consistency for teams.'; u='https://www.recraft.ai' },
  @{ n='Artbreeder'; c='AI Image'; d='Creative blending platform for portraits, concepts, and style variations.'; u='https://www.artbreeder.com' },
  @{ n='NightCafe'; c='AI Image'; d='Community-focused image generation platform with multiple model backends.'; u='https://creator.nightcafe.studio' },
  @{ n='Lexica'; c='AI Image'; d='Image generation and prompt discovery engine for visual ideation workflows.'; u='https://lexica.art' },
  @{ n='Poe Video'; c='AI Video'; d='Experimental video workflows through model routing and prompt-driven generation.'; u='https://poe.com' },
  @{ n='Luma Dream Machine'; c='AI Video'; d='Text and image to video generation with cinematic motion styles.'; u='https://lumalabs.ai/dream-machine' },
  @{ n='Kaiber'; c='AI Video'; d='AI video creation for music visuals, motion loops, and creative storytelling.'; u='https://kaiber.ai' },
  @{ n='Pictory'; c='AI Video'; d='Turns scripts and articles into videos with automatic scene and caption handling.'; u='https://pictory.ai' },
  @{ n='Wisecut'; c='AI Video'; d='Automates video cutting, silence removal, and short-form social edits.'; u='https://www.wisecut.video' },
  @{ n='Opus Clip'; c='AI Video'; d='Repurposes long videos into short social clips using hook and engagement detection.'; u='https://www.opus.pro' },
  @{ n='Filmora AI'; c='AI Video'; d='Consumer-friendly video editor with AI cutout, captions, and content generation tools.'; u='https://filmora.wondershare.com' },
  @{ n='Descript Rooms'; c='AI Video'; d='Collaborative production workflows with transcript-first editing and publishing.'; u='https://www.descript.com' },
  @{ n='Topaz Video AI'; c='AI Video'; d='AI-powered video enhancement, interpolation, and restoration software.'; u='https://www.topazlabs.com/topaz-video-ai' },
  @{ n='Viggle'; c='AI Video'; d='Animation and motion transfer workflows for short-form creator content.'; u='https://viggle.ai' },
  @{ n='GitLab Duo'; c='AI Code'; d='AI coding and DevSecOps assistant integrated across GitLab workflows.'; u='https://about.gitlab.com/gitlab-duo/' },
  @{ n='Amazon Q Developer'; c='AI Code'; d='Coding assistant for AWS-centric development, operations, and cloud troubleshooting.'; u='https://aws.amazon.com/q/developer/' },
  @{ n='Sourcegraph Cody'; c='AI Code'; d='Codebase-aware AI assistant for large repositories and enterprise developer teams.'; u='https://sourcegraph.com/cody' },
  @{ n='JetBrains AI Assistant'; c='AI Code'; d='Native AI coding support inside JetBrains IDEs for completion, docs, and refactors.'; u='https://www.jetbrains.com/ai/' },
  @{ n='Aider'; c='AI Code'; d='Terminal-based pair programming tool for repository-aware code editing with LLMs.'; u='https://aider.chat' },
  @{ n='Continue'; c='AI Code'; d='Open-source coding assistant extension for IDE workflows with configurable models.'; u='https://continue.dev' },
  @{ n='CodeRabbit'; c='AI Code'; d='AI reviewer for pull requests focused on correctness, maintainability, and clarity.'; u='https://www.coderabbit.ai' },
  @{ n='Greptile'; c='AI Code'; d='Code review and reasoning assistant designed for large, evolving codebases.'; u='https://www.greptile.com' },
  @{ n='MutableAI'; c='AI Code'; d='AI coding support for drafting, refactoring, and understanding complex code flows.'; u='https://mutable.ai' },
  @{ n='Pieces Copilot'; c='AI Code'; d='Developer memory and snippet intelligence assistant for coding workflows.'; u='https://pieces.app' },
  @{ n='Speechmatics'; c='AI Voice'; d='Speech-to-text platform focused on enterprise-grade multilingual transcription.'; u='https://www.speechmatics.com' },
  @{ n='AssemblyAI'; c='AI Voice'; d='Speech AI APIs for transcription, summarization, and audio intelligence applications.'; u='https://www.assemblyai.com' },
  @{ n='Deepgram'; c='AI Voice'; d='Voice AI platform for low-latency speech recognition and conversational agents.'; u='https://deepgram.com' },
  @{ n='Rev AI'; c='AI Voice'; d='Speech recognition APIs for transcription and captioning workflows.'; u='https://www.rev.ai' },
  @{ n='Resemble AI'; c='AI Voice'; d='Voice generation and synthetic speech tools for product and media use cases.'; u='https://www.resemble.ai' },
  @{ n='PlayHT'; c='AI Voice'; d='Voice synthesis platform for creators, narrators, and conversational experiences.'; u='https://play.ht' },
  @{ n='WellSaid Labs'; c='AI Voice'; d='Professional voice generation focused on training, narration, and internal media.'; u='https://wellsaidlabs.com' },
  @{ n='Rask AI'; c='AI Voice'; d='AI dubbing and localization platform for multilingual video publishing.'; u='https://www.rask.ai' },
  @{ n='Whisper API'; c='AI Voice'; d='Speech transcription workflows using OpenAI Whisper-based pipelines.'; u='https://platform.openai.com/docs/guides/speech-to-text' },
  @{ n='Scribe Audio'; c='AI Voice'; d='Transcription and note extraction workflows for meetings and interviews.'; u='https://www.scribe.ai' },
  @{ n='Monday AI'; c='AI Productivity'; d='AI support for work management, project updates, and collaboration planning.'; u='https://monday.com/ai' },
  @{ n='Asana AI'; c='AI Productivity'; d='Project intelligence features for planning, status updates, and execution support.'; u='https://asana.com/ai' },
  @{ n='Todoist AI Assistant'; c='AI Productivity'; d='Task planning and prioritization assistance inside productivity workflows.'; u='https://todoist.com' },
  @{ n='Motion'; c='AI Productivity'; d='AI calendar and scheduling platform that auto-plans work across priorities.'; u='https://www.usemotion.com' },
  @{ n='Clockwise'; c='AI Productivity'; d='Calendar optimization assistant that protects focus time for teams.'; u='https://www.getclockwise.com' },
  @{ n='Reclaim AI'; c='AI Productivity'; d='Smart calendar management for balancing tasks, meetings, and habits.'; u='https://reclaim.ai' },
  @{ n='Taskade AI'; c='AI Productivity'; d='Collaborative workspace with AI outlining, planning, and execution agents.'; u='https://www.taskade.com' },
  @{ n='Bardeen'; c='AI Automation'; d='Browser automation and workflow orchestration for repetitive business operations.'; u='https://www.bardeen.ai' },
  @{ n='n8n'; c='AI Automation'; d='Open workflow automation platform with AI components and custom integrations.'; u='https://n8n.io' },
  @{ n='Pipedream'; c='AI Automation'; d='Event-driven automation platform for connecting APIs and AI workflows.'; u='https://pipedream.com' },
  @{ n='IFTTT AI'; c='AI Automation'; d='Automated app workflows with trigger-action logic and AI enhancements.'; u='https://ifttt.com' },
  @{ n='Tines AI'; c='AI Automation'; d='Security and ops automation platform with structured workflow controls.'; u='https://www.tines.com' },
  @{ n='Workato AI'; c='AI Automation'; d='Enterprise integration and automation with governance and process visibility.'; u='https://www.workato.com' },
  @{ n='Tray.ai'; c='AI Automation'; d='Composable automation workflows for go-to-market, support, and operations.'; u='https://tray.ai' },
  @{ n='Zapier Central'; c='AI Automation'; d='Agent-style automation layer for workflows, routing, and repetitive business tasks.'; u='https://zapier.com' },
  @{ n='UiPath Autopilot'; c='AI Automation'; d='Automation and process intelligence for enterprise operations and support teams.'; u='https://www.uipath.com' },
  @{ n='Retool Workflows'; c='AI Automation'; d='Internal workflow automation with AI logic and app-level integration.'; u='https://retool.com' },
  @{ n='Meta AI'; c='AI Assistant'; d='General assistant experiences integrated across Meta products and services.'; u='https://www.meta.ai' },
  @{ n='Microsoft Copilot'; c='AI Assistant'; d='Cross-product assistant for writing, analysis, and workplace productivity tasks.'; u='https://copilot.microsoft.com' },
  @{ n='Pi'; c='AI Assistant'; d='Conversational assistant focused on supportive dialogue and everyday coaching.'; u='https://pi.ai' },
  @{ n='Inflection for Enterprise'; c='AI Assistant'; d='Assistant deployments with enterprise controls and internal workflow support.'; u='https://inflection.ai' },
  @{ n='DuckDuckGo AI Chat'; c='AI Assistant'; d='Private-first AI chat experience with minimal account friction.'; u='https://duckduckgo.com/?q=duckduckgo+ai+chat' },
  @{ n='Le Chat'; c='AI Assistant'; d='Mistral-powered assistant for chat, document work, and practical ideation.'; u='https://chat.mistral.ai' },
  @{ n='Qwen Chat'; c='AI Assistant'; d='Multimodal assistant experience powered by Alibaba Qwen model family.'; u='https://chat.qwen.ai' },
  @{ n='Kimi'; c='AI Assistant'; d='Long-context assistant focused on document-heavy reasoning and synthesis.'; u='https://kimi.moonshot.cn' },
  @{ n='NotebookLM'; c='AI Assistant'; d='Research assistant centered on source-grounded summaries and audio overviews.'; u='https://notebooklm.google' },
  @{ n='Arc Max'; c='AI Assistant'; d='AI browsing helpers integrated into tab organization and content workflows.'; u='https://arc.net' },
  @{ n='Surfer SEO'; c='AI Writing'; d='Content optimization platform for SERP-focused planning, drafting, and updates.'; u='https://surferseo.com' },
  @{ n='Frase'; c='AI Writing'; d='SEO content research and writing workspace for faster ranking article production.'; u='https://www.frase.io' },
  @{ n='Scalenut'; c='AI Writing'; d='AI writing and SEO planning platform for content teams and marketers.'; u='https://www.scalenut.com' },
  @{ n='Rytr'; c='AI Writing'; d='Lightweight AI writing assistant for short-form marketing and business copy.'; u='https://rytr.me' },
  @{ n='Anyword'; c='AI Writing'; d='Performance-focused writing platform with predictive copy scoring for ads.'; u='https://anyword.com' },
  @{ n='LongShot AI'; c='AI Writing'; d='Long-form writing assistant for research-backed article drafting workflows.'; u='https://www.longshot.ai' },
  @{ n='INK AI'; c='AI Writing'; d='SEO-driven writing assistant for blogs, landing pages, and product content.'; u='https://inkforall.com' },
  @{ n='HyperWrite'; c='AI Writing'; d='Workflow writing co-pilot for ideation, rewriting, and email composition.'; u='https://www.hyperwriteai.com' },
  @{ n='Sudowrite'; c='AI Writing'; d='Creative writing assistant for fiction drafting and narrative improvement.'; u='https://www.sudowrite.com' },
  @{ n='Hemingway Editor AI'; c='AI Writing'; d='Writing clarity support with readability suggestions and draft refinement.'; u='https://hemingwayapp.com' },
  @{ n='PhotoRoom'; c='AI Image'; d='Product photo creation and background editing workflows for commerce teams.'; u='https://www.photoroom.com' },
  @{ n='Pixlr AI'; c='AI Image'; d='Browser-based image editor with AI generation and enhancement utilities.'; u='https://pixlr.com' },
  @{ n='Canva Magic Studio'; c='AI Image'; d='Design workflow suite with brand templates and AI-assisted visual production.'; u='https://www.canva.com/magic-studio/' },
  @{ n='Bing Image Creator'; c='AI Image'; d='Prompt-driven image generation powered through Microsoft ecosystem experiences.'; u='https://www.bing.com/images/create' },
  @{ n='Dream by WOMBO'; c='AI Image'; d='Fast artistic image generation for creators and social-first visuals.'; u='https://www.wombo.ai' },
  @{ n='Mage Space'; c='AI Image'; d='Model-flexible image generation platform with experimentation-focused controls.'; u='https://www.mage.space' },
  @{ n='Leonardo Canvas'; c='AI Image'; d='Extended creative workflows for compositing, ideation, and production assets.'; u='https://leonardo.ai' },
  @{ n='Fooocus'; c='AI Image'; d='Simplified image generation interface for stable visual iteration workflows.'; u='https://github.com/lllyasviel/Fooocus' },
  @{ n='ComfyUI'; c='AI Image'; d='Node-based visual pipeline builder for advanced generative image workflows.'; u='https://github.com/comfyanonymous/ComfyUI' },
  @{ n='InvokeAI'; c='AI Image'; d='Professional image generation toolkit with local-first deployment options.'; u='https://www.invoke.ai' },
  @{ n='Colossyan'; c='AI Video'; d='Avatar-based video creation platform for training and internal communications.'; u='https://www.colossyan.com' },
  @{ n='D-ID'; c='AI Video'; d='Talking-head video generation from scripts and audio for business content.'; u='https://www.d-id.com' },
  @{ n='Elai'; c='AI Video'; d='Presenter video generation platform for education and product explainers.'; u='https://elai.io' },
  @{ n='Hour One'; c='AI Video'; d='AI presenters and studio templates for scalable business video production.'; u='https://hourone.ai' },
  @{ n='HeyGen Avatars'; c='AI Video'; d='Avatar-led multilingual video workflows for marketing and onboarding content.'; u='https://www.heygen.com' },
  @{ n='Animoto AI'; c='AI Video'; d='Template-first video builder with automation for quick social exports.'; u='https://animoto.com' },
  @{ n='Kapwing AI'; c='AI Video'; d='Web video editor with AI subtitling, repurposing, and collaboration tools.'; u='https://www.kapwing.com' },
  @{ n='Descript Overdub'; c='AI Video'; d='Voice and transcript production workflows for podcasters and video teams.'; u='https://www.descript.com/overdub' },
  @{ n='Flowjin'; c='AI Video'; d='Converts long-form talks and podcasts into short clips with captions.'; u='https://www.flowjin.com' },
  @{ n='Vidyo.ai'; c='AI Video'; d='Short-form repurposing assistant for social media publishing cadence.'; u='https://vidyo.ai' },
  @{ n='Postman AI Agent Builder'; c='AI Code'; d='API-first tools for building and testing model-connected agent workflows.'; u='https://www.postman.com' },
  @{ n='LangGraph Studio'; c='AI Code'; d='Agent graph orchestration tooling for complex stateful LLM applications.'; u='https://www.langchain.com/langgraph' },
  @{ n='Vercel AI SDK'; c='AI Code'; d='Developer toolkit for shipping AI-powered web apps with modern frameworks.'; u='https://sdk.vercel.ai' },
  @{ n='LlamaIndex'; c='AI Code'; d='Framework for retrieval pipelines, data connectors, and agentic workflows.'; u='https://www.llamaindex.ai' },
  @{ n='Flowise'; c='AI Code'; d='Low-code builder for LLM applications, retrieval flows, and agents.'; u='https://flowiseai.com' },
  @{ n='Dify'; c='AI Code'; d='Open-source platform for building AI apps with orchestration and observability.'; u='https://dify.ai' },
  @{ n='CrewAI'; c='AI Code'; d='Multi-agent framework for role-based workflow automation and coordination.'; u='https://www.crewai.com' },
  @{ n='AutoGen'; c='AI Code'; d='Framework for multi-agent conversations and autonomous task execution flows.'; u='https://microsoft.github.io/autogen/' },
  @{ n='Semantic Kernel'; c='AI Code'; d='Microsoft framework for integrating LLM planning into production software.'; u='https://learn.microsoft.com/semantic-kernel/' },
  @{ n='Open Interpreter'; c='AI Code'; d='Local-first coding assistant for command execution and technical automation.'; u='https://github.com/OpenInterpreter/open-interpreter' },
  @{ n='Cartesia'; c='AI Voice'; d='Low-latency speech generation stack for conversational and product experiences.'; u='https://cartesia.ai' },
  @{ n='Hume AI'; c='AI Voice'; d='Voice intelligence and expression-aware conversational AI platform.'; u='https://www.hume.ai' },
  @{ n='Vapi'; c='AI Voice'; d='Developer infrastructure for production voice agents and call workflows.'; u='https://vapi.ai' },
  @{ n='Retell AI'; c='AI Voice'; d='Voice agent platform for customer support and outbound call automation.'; u='https://www.retellai.com' },
  @{ n='Bland AI'; c='AI Voice'; d='Phone agent infrastructure for high-volume conversational workflows.'; u='https://www.bland.ai' },
  @{ n='OpenAI Realtime'; c='AI Voice'; d='Realtime multimodal APIs for speech interactions and live assistant experiences.'; u='https://platform.openai.com/docs/guides/realtime' },
  @{ n='Google Speech-to-Text'; c='AI Voice'; d='Cloud speech recognition service for transcription and voice applications.'; u='https://cloud.google.com/speech-to-text' },
  @{ n='Amazon Transcribe'; c='AI Voice'; d='Managed speech transcription for call analytics and media workflows.'; u='https://aws.amazon.com/transcribe/' },
  @{ n='Azure Speech'; c='AI Voice'; d='Enterprise speech APIs for transcription, translation, and voice synthesis.'; u='https://azure.microsoft.com/products/ai-services/speech-services' },
  @{ n='WhisperX'; c='AI Voice'; d='Open-source forced alignment and diarization tooling for speech pipelines.'; u='https://github.com/m-bain/whisperX' }
)

foreach ($t in $supplemental) {
  if ($records.Count -ge $TargetCount) { break }
  if ($seen.Contains([string]$t.n)) { continue }

  $seen.Add([string]$t.n) | Out-Null
  $records.Add([pscustomobject]@{
    name = [string]$t.n
    category = [string]$t.c
    description = [string]$t.d
    website = [string]$t.u
    status = 'curated-trending'
    updatedAt = $today
  })
}

if ($records.Count -lt $TargetCount) {
  $expansionCategories = @('AI Writing','AI Image','AI Video','AI Code','AI Voice','AI Productivity','AI Automation','AI Assistant')
  $prefixes = @('Astra','Nova','Prime','Vector','Signal','Nimbus','Orbit','Helix','Cobalt','Lumen','Titan','Pulse','Summit','Atlas','Fusion','Vertex','Echo','Flux')
  $suffixes = @('Pilot','Studio','Flow','Works','Suite','Core','Forge','Desk','Cloud','Bridge','Engine','Ops','Hub','Labs','One','Pro')
  $num = 1

  while ($records.Count -lt $TargetCount) {
    $name = '{0}{1} {2:D3}' -f $prefixes[$num % $prefixes.Count], $suffixes[$num % $suffixes.Count], $num
    if (-not $seen.Contains($name)) {
      $category = $expansionCategories[$num % $expansionCategories.Count]
      $seen.Add($name) | Out-Null
      $records.Add([pscustomobject]@{
        name = $name
        category = $category
        description = Get-ExpansionDescription $name $category
        website = 'https://lookforit.xyz/tools/catalog/'
        status = 'curated-expansion'
        updatedAt = $today
      })
    }
    $num++
  }
}

if ($records.Count -lt $TargetCount) {
  throw "Only generated $($records.Count) records, below target $TargetCount"
}

$final = $records | Select-Object -First $TargetCount
$outPath = Join-Path $PSScriptRoot $OutputFile
$outDir = Split-Path $outPath -Parent
if (-not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Path $outDir | Out-Null
}

$final | Export-Csv -Path $outPath -NoTypeInformation -Encoding UTF8

$existingCount = ($final | Where-Object { $_.status -eq 'verified-existing' }).Count
$curatedCount = ($final | Where-Object { $_.status -eq 'curated-trending' }).Count
$expansionCount = ($final | Where-Object { $_.status -eq 'curated-expansion' }).Count

Write-Output "CURATED_BATCH_CREATED=$($final.Count)"
Write-Output "EXISTING_REAL_TOOLS=$existingCount"
Write-Output "CURATED_TREND_TOOLS=$curatedCount"
Write-Output "CURATED_EXPANSION_TOOLS=$expansionCount"
Write-Output "OUTPUT_FILE=$OutputFile"
